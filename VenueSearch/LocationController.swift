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

protocol LocationControllerDelegate {
    func locationChanged(latitude: Float, longitude: Float)
}

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
        
    }
}
