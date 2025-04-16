//
//  Untitled.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 08.04.2025.
//

import UIKit

final class RenderUtils {
    
    static func drawBookmark(view: UIView) {
        let frame = view.bounds
        let path = UIBezierPath()
        
        // Move to top left corner
        path.move(to: CGPoint(
            x: frame.minX,
            y: frame.minY
        ))
        
        // Line to top right corner
        path.addLine(to: CGPoint(
            x: frame.maxX,
            y: frame.minY
        ))
        
        // Line to the bottom right corner
        path.addLine(to: CGPoint(
            x: frame.maxX,
            y: frame.maxY
        ))
        
        // Line to the bookmark triangle shape "control point"
        path.addLine(to: CGPoint(
            x: frame.midX,
            y: frame.maxY * 0.6
        ))
        
        // Line to the bottom left corner
        path.addLine(to: CGPoint(
            x: frame.minX,
            y: frame.maxY
        ))
        
        // Line to the top left corner
        path.addLine(to: CGPoint(
            x: frame.minX,
            y: frame.minY
        ))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 3
        view.layer.addSublayer(shapeLayer)
    }
    
}
