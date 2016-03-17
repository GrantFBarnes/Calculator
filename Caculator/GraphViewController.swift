//
//  GraphViewController.swift
//  Calculator
//
//  Created by Grant Barnes on 3/10/16.
//  Copyright © 2016 Grant Barnes. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    var equation: String = "Graph" {
        didSet{
            updateUI()
        }
    }
    
    var brain = CalculatorBrain()
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateUI()
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet{
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "changeScale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "changeOrigin:"))
            let tapGesture = UITapGestureRecognizer(target: graphView, action: "resetGraph:")
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGesture)
        }
    }

    func updateUI(){
        graphView?.setNeedsDisplay()
        title = "\(equation)"
    }
    
    func getBrain(sender: GraphView) -> CalculatorBrain {
        return brain
    }
}
