//
//  ControlViewController.swift
//  BLECar
//
//  Created by LuzanovRoman on 24.11.2017.
//  Copyright © 2017 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

class ControlViewController: UIViewController, DirectionControlDelegate, SpeedControlDelegate {
    @IBOutlet weak var directionControl: DirectionControlView!
    @IBOutlet weak var speedControl: SpeedControlView!
    
    var mainPeripheral: CBPeripheral?
    var mainCharacteristic: CBCharacteristic?
    
    private var currentDirection: Int16 = -1   // 0...180 (-1 = no direction)
    private var currentSpeed: Int16 = 0        // -128...128 (0 = stop)
    private var lastDirection: Int16 = -1
    private var lastSpeed: Int16 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speedControl.delegate = self
        directionControl.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectPeripheral(_:)), name: .didDisconnectPeripheral, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didDisconnectPeripheral(_ notification: NSNotification) {
        if let peripheral = notification.object as? CBPeripheral, peripheral == mainPeripheral {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func sendDataIfNeeded() {
        guard let peripheral = mainPeripheral, let characteristic = mainCharacteristic else { return }
        
        if currentDirection != lastDirection || currentSpeed != lastSpeed {
            var direction = currentDirection != lastDirection ? currentDirection : -1;
            var speed = currentSpeed;
            var data = Data(buffer: UnsafeBufferPointer(start: &direction, count: 1))
            data.append(Data(buffer: UnsafeBufferPointer(start: &speed, count: 1)))
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            lastDirection = currentDirection
            lastSpeed = currentSpeed
        }
    }
    
    // Translate value from default range (from 0.0 to 1.0) to specific range (e.c. 0.2 to 0.8)
    private func limit(value: Float, min: Float, max: Float) -> Float {
        return min + value * (max - min)
    }
    
    // MARK:- DirectionControlDelegate
    func didChangeDirection(value: Float) {
        // Limit value if you need. Default value is 0...180
        let limitedValue = limit(value: value, min: 0.2, max: 0.8)
        currentDirection = Int16(180 * limitedValue)
        sendDataIfNeeded()
    }
    
    // MARK:- SpeedControlDelegate
    func didChangeSpeed(value: Float) {
        if value == 0.5 {
            currentSpeed = 0
        } else if value < 0.5 {
            currentSpeed = Int16(255.0 * ((0.4 - value) * 2.5))
        } else if value > 0.5 {
            currentSpeed = -Int16(255.0 * ((value - 0.6) * 2.5))
        }
        sendDataIfNeeded()
    }
}
