//
//  TaskTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
@testable import VenueSearch

class TaskTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testTaskReturnCorrectKey() {
//        let keyForExercise = Task.Exercise(.add).key
//        let keyForForm = Task.Form(.Validate(.AddSession)).key
//        
//        XCTAssertTrue(keyFormController == keyForForm && keyExerciseController == keyForExercise)
//    }
    
    func testLocationEquality() {
        let ex1 = Task.location(.start)
        let ex2 = Task.location(.start)
        
        XCTAssertTrue(ex1 == ex2)
    }
    
    func testMainViewOnlineShouldBeEqual() {

        let ex1 = Task.mainView(.online)
        let ex2 = Task.mainView(.online)
        
        XCTAssertTrue(ex1 == ex2)
    }
    
    func testMainViewOfflineShouldBeEqual() {
        
        let ex1 = Task.mainView(.offline)
        let ex2 = Task.mainView(.offline)
        
        XCTAssertTrue(ex1 == ex2)
    }
    
    func testMainViewOnlineShouldBeNotEqual() {
        
        let ex1 = Task.mainView(.fetching)
        let ex2 = Task.mainView(.displayData)
        
        XCTAssertFalse(ex1 == ex2)
    }
    
    func testAPIStartShouldBeEqual() {
        
        let ex1 = Task.api(.start)
        let ex2 = Task.api(.start)
        
        XCTAssertTrue(ex1 == ex2)
    }
    
    func testUnequalTasksShouldNotBeEqual() {
        XCTAssertNotEqual(Task.mainView(.displayData), Task.location(.start))
        XCTAssertNotEqual(Task.location(.start), Task.mainView(.displayData))
        XCTAssertNotEqual(Task.api(.getVenues), Task.location(.start))
        XCTAssertNotEqual(Task.api(.start), Task.mainView(.fetchFailed))
        XCTAssertNotEqual(Task.mainView(.displayData), Task.api(.getVenues))
        XCTAssertNotEqual(Task.location(.start), Task.api(.start))
    }
    
    func testTaskKeyShouldReturnCorrectKeys() {
        let mainView = Task.mainView(.displayData)
        let api = Task.api(.start)
        let location = Task.location(.start)
        
        XCTAssertEqual(mainView.key, keyMainViewController)
        XCTAssertEqual(api.key, keyAPIController)
        XCTAssertEqual(location.key, keyLocationController)
    }
}
