//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Grant Barnes on 2/15/16.
//  Copyright © 2016 Grant Barnes. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double)
        case Variable(String)
        case Constant(String,Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                case .Variable(let variable):
                    return variable
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = Dictionary<String,Double>()
    
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map{$0.description}
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    var description: String {
        let (result, _) = toInfix(opStack)
        return result + " ="
    }
    
    private func toInfix(ops: [Op]) -> (result: String, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()

            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
                
            case .UnaryOperation(let operationString, _):
                let operandEvaluation = toInfix(remainingOps)
                let operand = operandEvaluation.result
                if "\(operationString)" == "^2" || "\(operationString)" == "^3" || "\(operationString)" == "%" {
                    return ("(" + "\(operand)"+")" + "\(operationString)", operandEvaluation.remainingOps)
                }
                if "\(operationString)" == "1/x" {
                    return ("1/(" + "\(operand)"+")", operandEvaluation.remainingOps)
                }
                return ("\(operationString)" + "(" + "\(operand)"+")", operandEvaluation.remainingOps)
                
            case .BinaryOperation(let operationString, _):
                let op1Evaluation = toInfix(remainingOps)
                let operand1 = op1Evaluation.result
                let op2Evaluation = toInfix(op1Evaluation.remainingOps)
                let operand2 = op2Evaluation.result
                
                let op2: String
                if checkParenNeeded("\(operand2)") {
                    op2 = "(" + "\(operand2)"+")"
                } else {
                    op2 = "\(operand2)"
                }
                
                let op1: String
                if checkParenNeeded("\(operand1)") {
                    op1 = "(" + "\(operand1)"+")"
                } else {
                    op1 = "\(operand1)"
                }
                
                return (op2 + "\(operationString)" + op1, op2Evaluation.remainingOps)

            case .Variable(let symbol):
                if let _ = variableValues[symbol] {
                    return (symbol, remainingOps)
                } else {
                    return ("M", remainingOps)
                }
            
            case .Constant(let symbol, _):
                return (symbol, remainingOps)
            }
        }
        return ("?",ops)
    }

    private func checkParenNeeded(current: String) -> Bool {
        let checks: Array<Character> = ["×","÷","+","−","c","s","%","^","-","/"]
        for c in current.characters {
            if checks.contains(c) {
                return true
            }
        }
        return false
    }
    
    
    init() {
        
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×",*))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+",+))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√",sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("%") { $0 / 100 } )
        learnOp(Op.UnaryOperation("^2") { $0 * $0 } )
        learnOp(Op.UnaryOperation("±") { $0 * -1 } )
        learnOp(Op.UnaryOperation("1/x") { 1 / $0 } )
        learnOp(Op.UnaryOperation("^3") { $0 * $0 * $0 } )
        knownOps["π"] = Op.Constant("π",M_PI)
        knownOps["e"] = Op.Constant("e",M_E)

    }
    
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):

                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }

                
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                if let val = variableValues[symbol] {
                    return (val, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
                
            case .Constant(_, let operand):
                return (operand,remainingOps)
            }
        }
        return (nil,ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand((operand)))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        variableValues["M"] = NSNumberFormatter().numberFromString(symbol)!.doubleValue
        opStack.append(Op.Variable("M"))
        return evaluate()
    }
    
    func getVariableVal() -> Double? {
        opStack.append(Op.Variable("M"))
        return evaluate()
    }
    
    func setVariableVal(v: Double) {
        variableValues["M"] = v
    }
    
    func clear() {
        opStack = [Op]()
        variableValues = Dictionary<String,Double>()
    }
}