//
//  MainViewController.swift
//  BLECar
//
//  Created by LuzanovRoman on 24.11.2017.
//  Copyright © 2017 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var bleStatusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    private let mainServiceUUID = CBUUID(string: "FFE0") // FFE0 - default service UUID of HM-11 module
    private var mainCentralManager: CBCentralManager!
    private var mainCharacteristic: CBCharacteristic?
    private var mainPeripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCentralManager = CBCentralManager(delegate: self, queue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startScanIfNeeded), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopScan), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func startScanIfNeeded() {
        if mainCentralManager.state == .poweredOn && mainPeripheral == nil {
            mainCentralManager.scanForPeripherals(withServices: [mainServiceUUID], options: nil)
        }
    }
    
    @objc func stopScan() {
        if mainCentralManager.isScanning {
            mainCentralManager.stopScan()
        }
    }
    
    private func releaseMainPeripheral() {
        if mainPeripheral != nil {
            NotificationCenter.default.post(name: .didDisconnectPeripheral, object: mainPeripheral)
            startButton.isEnabled = false
            mainCharacteristic = nil
            mainPeripheral = nil
        }
    }
    
    private func updateUI () {
        bleStatusLabel.textColor = .lightGray
        
        switch mainCentralManager.state {
        case .poweredOff:
            bleStatusLabel.text = "Turn on bluetooth"
            bleStatusLabel.textColor = .red
            
        case .poweredOn:
            bleStatusLabel.text = mainCharacteristic == nil ? "Searching ..." : nil
            bleStatusLabel.textColor = mainCharacteristic == nil ? .lightGray : .green
            
        case .resetting:
            bleStatusLabel.text = "BLE is resetting"
            
        case .unauthorized:
            bleStatusLabel.text = "BLE is unauthorized"
            
        case .unknown:
            bleStatusLabel.text = "BLE unknown state"
            
        case .unsupported:
            bleStatusLabel.text = "Your device doesn't support BLE"
            
        @unknown default:
            bleStatusLabel.text = "BLE unknown state"
        }
        startButton.isEnabled = mainCharacteristic != nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controlViewController = segue.destination as? ControlViewController {
            controlViewController.mainCharacteristic = mainCharacteristic
            controlViewController.mainPeripheral = mainPeripheral
        }
    }
    
    // MARK:- CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if mainCentralManager.state != .poweredOn {
            releaseMainPeripheral()
        }
        startScanIfNeeded()
        updateUI()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        mainPeripheral = peripheral
        mainCentralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([mainServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheral.delegate = nil
        
        if let theMainPeripheral = mainPeripheral, theMainPeripheral == peripheral {
            releaseMainPeripheral()
            startScanIfNeeded()
            updateUI()
        }
    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == mainServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                mainCharacteristic = characteristic
                mainCentralManager.stopScan()
                updateUI()
                break
            }
        }
    }
}
