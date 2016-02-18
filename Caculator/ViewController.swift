//
//  ViewController.swift
//  Calculator
//
//  Created by Grant Barnes on 2/7/16.
//  Copyright © 2016 Grant Barnes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            if digit == "⬅︎" {
                display.text = String(display.text!.characters.dropLast())
                
            } else if digit == "±" {
                if display.text!.rangeOfString("-") == nil  {
                    display.text = "-" + display.text!
                } else {
                    display.text = String(display.text!.characters.dropFirst())
                }
                
            } else if digit == "." {
                if display.text!.rangeOfString(".") == nil  {
                    display.text = display.text! + digit
                }
            } else {
                display.text = display.text! + digit
            }
        } else {
            if digit != "⬅︎" && digit != "±"{
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func enter() {

        userIsInTheMiddleOfTypingANumber = false
        if let d = displayValue {
            
            if history.text!.rangeOfString(".") != nil {
                history.text = history.text! + ", \(d)"
            } else {
                history.text = history.text! + "\(d)"
            }
            
            if let result = brain.pushOperand(d) {
                displayValue = result
            } else {
                displayValue = 0
            }
        } else {
            displayValue = nil
        }

    }
    
    var displayValue: Double? {
        get {
            if let d = display.text {
                return NSNumberFormatter().numberFromString(d)!.doubleValue
            } else {
                return nil
            }
        }
        set {
            if let nv = newValue {
                display.text = "\(nv)"
            } else {
                display.text = "ERROR"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clear() {
        displayValue = 0
        history.text = nil
        brain.clear()
        history.text = "History: "
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {

            if let result = brain.performOperation(operation) {
                displayValue = result
                if history.text!.rangeOfString(".") != nil {
                    history.text = history.text! + ", " + operation
                } else {
                    history.text = history.text! + operation
                }
            } else {
                displayValue = nil
            }
        }
    }
}


