//
//  LocationController.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import CoreLocation
import DecouplerKit
import PromiseKit

/// A protocol used by observers which will receive coordinate information
protocol LocationControllerDelegate {
    /// This method is called when new location information is delivered.
    /// - parameter latitude: the latitude coordinate as a Float
    /// - parameter longitude: the longitude coordinate as a Float
    func locationChanged(latitude: Float, longitude: Float)
}

/// The LocationController encapsulates the location manager. A call to the
/// transmit interface with a start request and will initiate the location manager.
/// - important: the type parameter T is a CLLocationManager instance or an instance of a class that inherited from it. This solution helped in making the controller much more testable.
class LocationController<T: CLLocationManager>: NSObject, Interface, CLLocationManagerDelegate {
    
    private var locationManager:T!
    
    var delegate: LocationControllerDelegate?
    
    init(locationManager: T ) {
        super.init()
        self.locationManager = locationManager
    }
    
    func tx(request: Request) -> Promise<MessageContainer> {
        let task = request.process as! Task
        
        switch task {
            case .location(.start):
                return startReceivingLocationChanges(request:request)
            default:
                return Promise { seal in
                    seal.reject(AppError.generic(.undefined(message: NSLocalizedString("LocationController is unable to handle the task", comment: ""))))
                }
            }
    }
    
    /// The corelocation manager is initiated here.
    /// If the user did not give permission or the sensor is disabled a rejection promise is
    /// returned.
    /// - parameter request: a Request object
    /// - Returns:
    /// a Promise with a MessageContainer
    func startReceivingLocationChanges(request: Request) -> Promise<MessageContainer> {
        
        let authorizationStatus = T.authorizationStatus()
        
        if authorizationStatus != .authorizedWhenInUse {
            return Promise<MessageContainer> { seal in
                seal.reject(AppError.location(.notAuth))
            }
        }
        
        if !T.locationServicesEnabled() {
            return Promise<MessageContainer> { seal in
                seal.reject(AppError.location(.disabled))
            }
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 500.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        return Promise { seal in
            seal.fulfill(Response(proc: request.process))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let recent = locations.last
        delegate?.locationChanged(latitude: Float(recent!.coordinate.latitude), longitude: Float(recent!.coordinate.longitude))
    }
}
