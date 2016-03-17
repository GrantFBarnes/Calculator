//
//  GraphView.swift
//  Calculator
//
//  Created by Grant Barnes on 3/10/16.
//  Copyright © 2016 Grant Barnes. All rights reserved.
//

import UIKit


protocol GraphViewDataSource: class {
    func getBrain(sender: GraphView) -> CalculatorBrain
}

@IBDesignable
class GraphView: UIView {

    var drawer = AxesDrawer()
    
    var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable
    var lineColor: UIColor = UIColor.redColor() { didSet {setNeedsDisplay() }  }
    
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet {setNeedsDisplay() }  }
    
    @IBInspectable
    var scale: CGFloat = 50 { didSet{setNeedsDisplay()} }
    
    var origin: CGPoint = CGPoint(x: 0.0,y: 0.0) {didSet{ setNeedsDisplay()}}
    
    var originSet: Bool = false
    
    @IBAction func changeScale(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            scale *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
    @IBAction func changeOrigin(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            originSet = true
            let translation = gesture.translationInView(self)
            origin.y += translation.y / 35
            origin.x += translation.x / 35
        default: break
        }
    }
    
    @IBAction func resetGraph(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            origin = graphCenter
            scale = 50
        default: break
        }
    }
    
    override func drawRect(rect: CGRect) {
        if !originSet {
            origin = graphCenter
        }
        
        let brain = dataSource?.getBrain(self) ?? CalculatorBrain()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth: CGFloat = screenSize.width;
        let screenHeight: CGFloat = screenSize.height;
        
        let coordinates = getCoordinates(brain,screenx: screenWidth, screeny: screenHeight, scale: scale, origin: origin, rect: rect)
        
        if coordinates != nil {
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            
            path.moveToPoint(coordinates![0])
            for pixel in 1..<coordinates!.count {
                path.addLineToPoint(coordinates![pixel])
                path.moveToPoint(coordinates![pixel])
            }
            
            lineColor.set()
            path.stroke()
        }
        drawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
    }
    
    
    private func evaluate(b: CalculatorBrain, x: Double) -> Double? {
        
        if let val = b.evaluateForGraph(x) {
            return val
        } else {
            return nil
        }
    }
    
    private func getCoordinates(brain: CalculatorBrain, screenx: CGFloat, screeny: CGFloat,scale: CGFloat,origin: CGPoint, rect: CGRect) -> [CGPoint]? {
        
        let xlen = screenx/scale
        let originXscale = Double(((origin.x/screenx))*xlen)

        var xvals = [Double]()
        for x in 0...Int(xlen) {
            if xlen < 75 {
                for d in [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9] {
                    xvals.append((Double(x)+d)-originXscale)
                }
            } else {
                xvals.append(Double(x)-originXscale)
            }
        }
        
        var yvals = [Double?]()
        for x in xvals {
            yvals.append(evaluate(brain,x:x))
        }
        
        if yvals[0] != nil {
            let xTranslation = Double(origin.x)
            let yTranslation = Double(origin.y)
            
            var coordinates = [CGPoint]()
            for x in 0..<xvals.count {
                if yvals[x] != Double.infinity && !yvals[x]!.isNaN {
                    if yvals[x]!.isNormal || yvals[x]!.isZero {
                        let xval = xvals[x]*Double(scale) + xTranslation
                        let yval = -1*yvals[x]!*Double(scale) + yTranslation
                        coordinates.append(CGPoint(x: xval, y: yval))
                    }
                }
            }
            return coordinates
        }
        return nil
    }
}
