//
//  Canvas.swift
//  Draw
//
//  Created by Nate Madera on 1/1/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import UIKit

class Canvas: UIView {
    
    // MARK: Properties
    private var lines = [Line]()
    private var strokeColor: CGColor = UIColor.black.cgColor
    private var drawTool: DrawTool = .paintBrush
    
    private var isErasing: Bool {
        return drawTool == .eraser
    }
    
    var hasStarted: Bool {
        return !lines.isEmpty
    }
    
    // MARK: Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineCap(.round)
        
        lines.forEach() { line in
            context.setStrokeColor(line.color)
            context.setLineWidth(8.0)
            
            line.isEraser ? context.setBlendMode(CGBlendMode.clear) : context.setBlendMode(CGBlendMode.normal)
            
            for (index, point) in line.points.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        
            context.strokePath()
        }
    }
    
    // MARK: Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line(color: strokeColor, points: [CGPoint](), isEraser: isErasing))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: nil) else { return }
        guard var lastLine = lines.popLast() else { return }
        
        lastLine.points.append(point)
        lines.append(lastLine)
        
        setNeedsDisplay()
    }
}

// MARK: - Public Functions
extension Canvas {
    func setStrokeColor(_ color: UIColor) {
        strokeColor = color.cgColor
    }
    
    func setDrawTool(_ tool: DrawTool) {
        drawTool = tool
    }
    
    func undo() {
        _ = lines.popLast()
        setNeedsDisplay()
    }
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
}
