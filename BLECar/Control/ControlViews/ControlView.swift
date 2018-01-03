//
//  ControlView.swift
//  BLECar
//
//  Created by LuzanovRoman on 24.11.2017.
//  Copyright © 2017 LuzanovRoman. All rights reserved.
//

import UIKit

class ControlView: UIView {
    private let strokeColor: UIColor = UIColor(white: 0.2, alpha: 1)
    private let fillColor: UIColor = UIColor.white
    
    func newBezierPath(lineWidth: CGFloat) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = lineWidth
        return bezierPath
    }
    
    func closeAndDraw(bezierPath: UIBezierPath) {
        bezierPath.close()
        fillColor.set()
        bezierPath.fill()
        strokeColor.set()
        bezierPath.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        let lineWidth: CGFloat = 4
        let bezierPath = newBezierPath(lineWidth: lineWidth)
        let radius = bounds.size.width / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX,y: bounds.midY)
        bezierPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        closeAndDraw(bezierPath: bezierPath)
    }
}
