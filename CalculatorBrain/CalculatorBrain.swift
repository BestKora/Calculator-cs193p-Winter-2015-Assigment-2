//
//  CalculatorBrain.swift
//  Calculator
//
//   Created by Tatiana Kornilova on 2/5/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case ConstantOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .ConstantOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol

                }
            }
        }
    }

    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var variableValues = [String: Double]()
   
    func getVariable(symbol: String) -> Double? {
        return variableValues[symbol]
    }
    
    func setVariable(symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    func clearStack() {
        opStack.removeAll()
    }
    
    func clearAll() {
        clearVariables()
        clearStack()
    }
    
    init() {
        func learnOp (op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.ConstantOperation("π", { M_PI }))
        learnOp(Op.UnaryOperation("±", { -$0 }))
    }
    
    typealias PropertyList = AnyObject
    
    var program:PropertyList { // guaranteed to be a Property List
        get {
            return opStack.map{$0.description}
        }
        set{
            if let opSymbols = newValue as? Array<String> {
                
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description1: String {
        get {
            let (result, remainder) = descParts(opStack)
            //            println("\(opStack) = \(result) c остатком \(remainder)")
            return result ?? ""
        }
    }
    
    private func descParts(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        let (result, reminder) = description(ops)
        if !reminder.isEmpty {
            let (current, reminderCurrent) = descParts(reminder)
            return ("\(current!), \(result!)",reminderCurrent)
        }
        return (result,reminder)
    }

    var description: String {
        get {
            var (result, remainder) = ("", opStack)
            var current: String?
            do {
                (current, remainder) = description(remainder)
                result = result == "" ? current! : "\(current!), \(result)"
            } while remainder.count > 0
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
                
            case .Operand(let operand):
                return ( NumberFormatter.formatter.stringFromNumber(operand), remainingOps)
                
            case .ConstantOperation(let symbol, _):
                return (symbol, remainingOps);
                
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result {
                    if remainingOps.count - op1Evaluation.remainingOps.count > 2 {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps)
                    }
                }
                
            case .Variable(let symbol):
                return (symbol, remainingOps)
            }
        }
        return ("?", ops)
    }
    
   private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .ConstantOperation(_, let operation):
                return (operation(), remainingOps)
                
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
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func displayStack() -> String? {
             return opStack.isEmpty ? nil : " ".join(opStack.map{ $0.description })
    }

    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //let (result, _) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
            if result != nil {
            if result!.isNaN || result!.isInfinite {
                return nil
            }
        }
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
}

class NumberFormatter:NSNumberFormatter{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init() {
        super.init()
        self.locale = NSLocale.currentLocale()
        self.numberStyle = .DecimalStyle
        self.maximumFractionDigits = 10
        self.notANumberSymbol = "Error"
        self.groupingSeparator = " "
    }
    static var formatter = NumberFormatter()
}
