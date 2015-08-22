//
//  CalculatorBrainTests.swift
//  CalculatorBrainTests
//
//  Created by Tatiana Kornilova on 2/5/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit
import XCTest


class CalculatorBrainTests: XCTestCase {
     private var brain = CalculatorBrain()
    
    func testDescription() {
        // cos(10)
        XCTAssertEqual(brain.pushOperand(10)!, 10)
        XCTAssertTrue(brain.performOperation("cos")! - -0.839 < 0.1)
        XCTAssertEqual(brain.displayStack()!, "10.0 cos")
     }
    
}
