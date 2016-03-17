//
//  ViewController.swift
//  Calculator
//
//  Created by Grant Barnes on 2/7/16.
//  Copyright © 2016 Grant Barnes. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destination = segue.destinationViewController as UIViewController
        
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                let hist = history.text!.componentsSeparatedByString(", ")
                let c = hist.count
                var e = hist[c-1]
                if e == " " {
                    e = "Graph"
                }
                
                switch identifier {
                case "graph":
                    gvc.equation = e
                    gvc.brain = brain
                    
                default:
                    gvc.equation = "Graph"
                    gvc.brain = brain
                }
            }
        }
    }
    
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            if digit == "⬅︎" {
                let temp = String(display.text!.characters.dropLast())
                if temp == "" {
                    displayValue = 0
                } else {
                    display.text = temp
                }
                
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
            
            if let result = brain.pushOperand(d) {
                displayValue = result
            } else {
                displayValue = 0
            }
            
            if history.text != " " {
                history.text = String(history.text!.characters.dropLast()) + ", " + brain.description
            } else {
                history.text = brain.description
            }
            
        } else {
            displayValue = nil
        }
    }
    
    var displayValue: Double? {
        get {
            if let d = display.text {
                if d == "ERROR" {
                    return nil
                }
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
        brain.clear()
        history.text = " "
    }

    @IBAction func setVariable() {
        if let d = display.text {
            if d != "ERROR" {
                brain.setVariableVal(NSNumberFormatter().numberFromString(d)!.doubleValue)
                userIsInTheMiddleOfTypingANumber = false
                if let v = brain.evaluate() {
                    displayValue = v
                } else {
                    displayValue = 0
                }
            }
        }
    }
    
    @IBAction func getVariable() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        let val = brain.getVariableVal()
        displayValue = val
        if history.text != " " {
            history.text = String(history.text!.characters.dropLast()) + ", " + brain.description
        } else {
            history.text = brain.description
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {

            if let result = brain.performOperation(operation) {
                displayValue = result
                
                if history.text != " " {
                    let (new,len) = splitHistory(operation)
                    if len >= 1 {
                        history.text = new + ", " + brain.description
                    } else {
                        history.text =  brain.description
                    }
                    
                } else {
                    history.text = brain.description
                }

            } else {

                if history.text!.containsString("M") {
                    let (new,len) = splitHistory(operation)
                    if len >= 1 {
                        history.text = new + ", " + brain.description
                    } else {
                        history.text =  brain.description
                    }
                } else {
                    history.text = brain.description
                }
                displayValue = nil
            }
        }
    }
    
    func splitHistory(op: String)-> (String, Int) {
        let consts = ["π","e"]
        let unary = ["√","cos","sin","%","^2","±","1/x","^3"]
        var prev = history.text!.componentsSeparatedByString(", ")
        
        if unary.contains(op) {
            if prev.count >= 1 {
                prev.removeLast()
            }
        } else if consts.contains(op) {
            var new = prev[prev.count-1]
            new = String(new.characters.dropLast())
            new = String(new.characters.dropLast())
            prev[prev.count-1] = new
        } else {
            if prev.count >= 2 {
                prev.removeLast()
                prev.removeLast()
            } else if prev.count >= 1{
                prev.removeLast()
            }
        }
        
        var result = ""
        for c in prev {
            result = result + c + ", "
        }
        
        result = String(result.characters.dropLast())
        return (String(result.characters.dropLast()), prev.count)
    }
}