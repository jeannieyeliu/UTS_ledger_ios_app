//
//  ProgressUIView.swift
//  MoMo
//
//  Created by BonnieLee on 25/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

class ProgressUIView: UIView {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.5)
        context?.setStrokeColor(UIColor.lightBlue.cgColor)
        context?.setFillColor(UIColor.oceanBlue.cgColor)
        
        context?.addRect(CGRect(x: 0, y: 0, width: 100, height: self.bounds.maxY))
        context?.drawPath(using: .fill)
        
        context?.move(to: CGPoint(x:50, y: 3))
        context?.addLine(to: CGPoint(x: 50, y: self.bounds.maxY - 3))
        context?.strokePath()
    }
}
