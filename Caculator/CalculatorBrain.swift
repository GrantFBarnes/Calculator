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
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
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
        knownOps["π"] = Op.Operand(M_PI)

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
            }
        }
        
        return (nil,ops)
        
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        //print("\(opStack) = \(result) with \(remainder) left over ")
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
    
    func clear() {
        opStack = [Op]()
    }
}
