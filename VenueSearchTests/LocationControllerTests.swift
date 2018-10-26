//
//  LocationTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
import DecouplerKit
@testable import VenueSearch

class LocationControllerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartReceivingChangesWhileAuthIsNotDeterminedShouldBeRejected() {
        FakeLocationManagerData.sharedInstance.locationServicesEnabled = false
        let mockManager = MockLocationManager()
        let request = Request(proc: Task.location(.start))
        let locationController = LocationController(locationManager: mockManager)
        let promise = locationController.tx(request: request)
        XCTAssertTrue(promise.isRejected)
    }
    
    func testStartReceivingChangesWhileSensorDisabledShouldReturnDisabledError() {
        FakeLocationManagerData.sharedInstance.currentAuthStatus = .authorizedWhenInUse
        FakeLocationManagerData.sharedInstance.locationServicesEnabled = false
        let mockManager = MockLocationManager()
        let request = Request(proc: Task.location(.start))
        let locationController = LocationController(locationManager: mockManager)
        let promise = locationController.tx(request: request)
        
        XCTAssertTrue(promise.isRejected)
        
        let err:AppError = promise.error! as! AppError
        
        switch err {
            case .location(.disabled):
                XCTAssertTrue(true)
            default:
                XCTAssertTrue(false)
        }
    }
    
    func testStartReceivingChangesWithIncorrectAuthReturnNotAuthError() {
        FakeLocationManagerData.sharedInstance.currentAuthStatus = .authorizedAlways
        FakeLocationManagerData.sharedInstance.locationServicesEnabled = true
        let mockManager = MockLocationManager()
        let request = Request(proc: Task.location(.start))
        let locationController = LocationController(locationManager: mockManager)
        let promise = locationController.tx(request: request)
        
        XCTAssertTrue(promise.isRejected)
        
        let err:AppError = promise.error! as! AppError
        
        switch err {
        case .location(.notAuth):
            XCTAssertTrue(true)
        default:
            XCTAssertTrue(false)
        }
    }
    
    func testStartReceivingChangesWithSensorEnabledAndAuthShouldSucceed() {
        FakeLocationManagerData.sharedInstance.currentAuthStatus = .authorizedWhenInUse
        FakeLocationManagerData.sharedInstance.locationServicesEnabled = true
        let mockManager = MockLocationManager()
        let request = Request(proc: Task.location(.start))
        let locationController = LocationController(locationManager: mockManager)
        let promise = locationController.tx(request: request)
        
        XCTAssertTrue(promise.isFulfilled)
    }
}
