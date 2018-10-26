//
//  TestUtil.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import CoreLocation

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
