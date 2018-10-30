//
//  ErrorTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
@testable import VenueSearch

class ErrorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLocationShouldBeEqual() {
        let e1 = AppError.location(.disabled)
        let e2 = AppError.location(.disabled)
        
        XCTAssertEqual(e1, e2)
    }
    
    func testLocationShouldNotBeEqual() {
        let e1 = AppError.location(.disabled)
        let e2 = AppError.location(.notAuth)
        
        XCTAssertNotEqual(e1, e2)
    }
    
    func testUnequalErrorsShouldNotBeEqual() {
        XCTAssertNotEqual(AppError.generic(.undefined(message: "")), AppError.location(.disabled))
        XCTAssertNotEqual(AppError.location(.disabled), AppError.generic(.undefined(message: "")))
    }
    
    func testGenericErrorWithSetMessageShouldReturnMessage() {
        let message = "some message 1234"
        let err = AppError.generic(.undefined(message: message))
        XCTAssertEqual(message, err.errorDescription)
    }
}
