//
//  DirectionControlView.swift
//  BLECar
//
//  Created by LuzanovRoman on 24.11.2017.
//  Copyright © 2017 LuzanovRoman. All rights reserved.
//

import UIKit

protocol DirectionControlDelegate: NSObjectProtocol {
    func didChangeDirection(value: Float)
}

class DirectionControlView: ControlView {
    @IBOutlet weak var slider: UIView!
    weak var delegate: DirectionControlDelegate?
    
    private var position_: CGFloat = 0.5
    private var position: CGFloat {
        get {
            return position_;
        }
        set {
            if (position_ != newValue) {
                position_ = newValue
                delegate?.didChangeDirection(value: Float(newValue))
            }
        }
    }
    
    var maxPostition: CGFloat {
        get {
            return self.bounds.size.width - slider.frame.size.width
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let bezierPath = newBezierPath(lineWidth: 4)
        bezierPath.move(to: CGPoint(x: rect.width * 0.1, y: rect.midY))
        bezierPath.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.midY))
        closeAndDraw(bezierPath: bezierPath)
    }
    
    @objc func pan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            slider.frame.origin.x += translation.x
            slider.frame.origin.x = min(maxPostition, max(0, slider.frame.origin.x))
            recognizer.setTranslation(CGPoint.zero, in: self)
            position = slider.frame.origin.x / maxPostition
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        slider.frame.origin.x = position * maxPostition
    }
}
