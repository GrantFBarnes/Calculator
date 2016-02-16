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
        if history.text!.rangeOfString(".") != nil {
            history.text = history.text! + ", \(displayValue)"
        } else {
            history.text = history.text! + "\(displayValue)"
        }
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
        
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clear() {
        displayValue = 0
        history.text = nil
        brain.clear()
        history.text = "Hist: "
        
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if history.text!.rangeOfString(".") != nil {
                history.text = history.text! + ", " + operation
            } else {
                history.text = history.text! + operation
            }
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        
    }
}


