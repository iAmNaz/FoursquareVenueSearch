//
//  LocationTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
import DecouplerKit
import CoreLocation

@testable import VenueSearch

class LocationControllerTests: XCTestCase {

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
        XCTAssertEqual(err, AppError.location(.notAuth))
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
    
    func testLocationControllerByPassingUnrecognizedTaskTypeShouldReturnError() {
        FakeLocationManagerData.sharedInstance.currentAuthStatus = .authorizedWhenInUse
        FakeLocationManagerData.sharedInstance.locationServicesEnabled = true
        let mockManager = MockLocationManager()
        
        let request = Request(proc: Task.mainView(.offline))
        let locationController = LocationController(locationManager: mockManager)
        let promise = locationController.tx(request: request)
        
        XCTAssertTrue(promise.isRejected)
        
        let err:AppError = promise.error! as! AppError
        XCTAssertEqual(err, AppError.generic(.undefined(message: NSLocalizedString("LocationController is unable to handle the task", comment: ""))))
    }
   
    func testLocationControllerDelegateSetAndCalledOnLocationUpdate(){
        FakeLocationManagerData.sharedInstance.currentAuthStatus = .authorizedWhenInUse
        FakeLocationManagerData.sharedInstance.locationServicesEnabled = true
        
        let mockManager = MockLocationManager()
        let mockLocation = CLLocation(latitude: 0, longitude: 0)
        
        let delegate = MockLocationControllerDelegate()
        let locationController = LocationController(locationManager: mockManager)
            locationController.delegate = delegate
        
        mockManager.delegate = locationController
        mockManager.delegate?.locationManager!(mockManager, didUpdateLocations: [mockLocation])
        
        XCTAssertTrue(delegate.updateCalled)
    }
}
