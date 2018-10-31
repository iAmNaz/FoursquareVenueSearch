//
//  TestUtil.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import CoreLocation
import DecouplerKit
import PromiseKit

@testable import VenueSearch

class MockAPIController: APIController {
    var reloadCalled: Bool!
    
    override func reloadList(latitude: Float, longitude: Float) {
        reloadCalled = true
    }
    

}

class FakeLocationManagerData {
    var currentAuthStatus = CLAuthorizationStatus.notDetermined
    var locationServicesEnabled = false
    static let sharedInstance = FakeLocationManagerData()
}

class MockLocationManager: CLLocationManager {
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return FakeLocationManagerData.sharedInstance.currentAuthStatus
    }
    
    override class func locationServicesEnabled() -> Bool {
        return FakeLocationManagerData.sharedInstance.locationServicesEnabled
    }
}

class MockLocationControllerDelegate: LocationControllerDelegate{
    var currentLocation: CLLocationCoordinate2D!
    var updateCalled = false
    
    func locationChanged(latitude: Float, longitude: Float) {
        updateCalled = true
    }
}

class MockTxReceiver: NSObject, Interface {
    var currentMessage: Task!
    
    func tx(request: Request) -> Promise<MessageContainer> {
        currentMessage = request.process as? Task
        return Promise { seal in
            seal.fulfill(Response(proc: request.process))
        }
    }
}

typealias CompletionBlock = (Request) -> Void
var completionBlock: CompletionBlock?
class MockRegistry: ResponderRegistry {

    var currentTask: Task!
    var request: Request!
    var taskReceived: CompletionBlock?
    
    override func tx(request: Request) -> Promise<MessageContainer> {
        self.request = request
        
        if taskReceived != nil {
            taskReceived!(request)
        }
        
        currentTask = request.process as? Task
        return Promise { seal in
            seal.fulfill(Response(proc: request.process))
        }
    }
}


protocol ReachabilityProtocol {
    var connection: Connection { get }
}

class MockReachability: Reachability {
    var currentConn: Connection!
    var shouldThrow = false
    
    override func connection() -> Connection {
        return currentConn
    }
    
    @objc override func startNotifier() throws {
        if shouldThrow {
            throw ReachabilityError.UnableToSetCallback
        }
    }
}
