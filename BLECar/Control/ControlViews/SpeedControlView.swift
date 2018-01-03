//
//  SpeedControlView.swift
//  BLECar
//
//  Created by LuzanovRoman on 24.11.2017.
//  Copyright © 2017 LuzanovRoman. All rights reserved.
//

import UIKit

protocol SpeedControlDelegate: NSObjectProtocol {
    func didChangeSpeed(value: Float)
}

class SpeedControlView: ControlView {
    @IBOutlet weak var slider: UIView!
    weak var delegate: SpeedControlDelegate?
    
    private var position_: CGFloat = 0.5
    private var position: CGFloat  {
        get {
            return position_;
        }
        set {
            let value = newValue > 0.4 && newValue < 0.6 ? 0.5 : newValue
            
            if (position_ != value) {
                position_ = value
                delegate?.didChangeSpeed(value: Float(value))
            }
        }
    }
    
    var minPostition: CGFloat {
        get {
            return self.bounds.size.height - slider.frame.size.height
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
    }
    
    @objc func pan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            slider.frame.origin.y += translation.y
            slider.frame.origin.y = min(minPostition, max(0, slider.frame.origin.y))
            recognizer.setTranslation(CGPoint.zero, in: self)
            position = slider.frame.origin.y / minPostition
        }
        if recognizer.state == .cancelled || recognizer.state == .ended {
            position = 0.5
            
            var rect = slider.frame
            rect.origin.y = self.frame.size.height / 2 - rect.size.height / 2
            
            UIView.animate(withDuration: 0.3, animations: {
                self.slider.frame = rect
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        slider.frame.origin.y = position * minPostition
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let lineWidth: CGFloat = 4
        var bezierPath = newBezierPath(lineWidth: lineWidth)
        bezierPath.move(to: CGPoint(x: rect.midX, y: rect.size.height * 0.1))
        bezierPath.addLine(to: CGPoint(x: rect.midX, y: rect.size.height * 0.4))
        closeAndDraw(bezierPath: bezierPath)
        
        bezierPath = newBezierPath(lineWidth: lineWidth)
        bezierPath.move(to: CGPoint(x: rect.midX, y: rect.size.height * 0.6))
        bezierPath.addLine(to: CGPoint(x: rect.midX, y: rect.size.height * 0.9))
        closeAndDraw(bezierPath: bezierPath)
    }
}
