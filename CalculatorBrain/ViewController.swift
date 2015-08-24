//
//  ViewController.swift
//  CalculatorBrain
//
//  Created by Tatiana Kornilova on 2/5/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var tochka: UIButton! {
        didSet {
            tochka.setTitle(decimalSeparator, forState: UIControlState.Normal)
        }
    }

    let decimalSeparator =  NSNumberFormatter().decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()

    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            
             //----- Не пускаем избыточную точку ---------------
            if (digit == decimalSeparator) && (display.text?.rangeOfString(decimalSeparator) != nil) { return }
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit != decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
                                                                              { display.text = digit ; return }
            //--------------------------------------------------
            
            display.text = display.text! + digit
        } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                 displayValue = result
                 history.text =  history.text! + " ="
            } else {
                // error?
                displayValue = nil  // задание 2
                history.text =  history.text! + " = Error"
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
               displayValue = brain.pushOperand(value)
            } else {
               displayValue = nil
        }
     }
    
    @IBAction func setVariable(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        let symbol = dropFirst(sender.currentTitle!)
        if let value = displayValue {
            brain.setVariable(symbol, value: value)
            displayValue = brain.evaluate()
        }

    }
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayValue = brain.pushOperand(sender.currentTitle!)
    }
    
    @IBAction func clearAll(sender: AnyObject) {
          brain.clearAll()
          displayValue = 0
    }
 
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            if count(display.text!) > 1 {
                display.text = dropLast(display.text!)
            } else {
                display.text = "0"
            }
        } else {
            displayValue = brain.popStack()
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text!.rangeOfString("-") != nil) {
                display.text = dropFirst(display.text!)
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
               return NumberFormatter.formatter.numberFromString(displayText)?.doubleValue
            }
            return nil
        }
        set {
            if (newValue != nil) {
             //  display.text = "\(newValue!)"
               display.text = NumberFormatter.formatter.stringFromNumber(newValue!)
            } else {
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumber = false
            
            //          history.text = brain.displayStack()
            //          history.text = brain.description
            
            history.text = brain.description1
        }
    }    
}

