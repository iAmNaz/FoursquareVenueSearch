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
    var uiRegistry: ResponderRegistry!
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
            case .location(.online):
                return requestForLocationWhenOnline(request: request)
            default:
                return Promise { seal in
                    seal.reject(AppError.generic(.undefined(message: NSLocalizedString("LocationController is unable to handle the task", comment: ""))))
                }
            }
    }
    
    /// Whenever the app is connected to the internet a new venue list is requested
    /// While previous location information is not used to fill the list with venues
    /// stopping and starting location updates triggers a new location event
    /// which causes the app to reload the venue list
    /// - parameter request: a Request object
    /// - Returns:
    /// a Promise with a MessageContainer
    private func requestForLocationWhenOnline(request: Request) -> Promise<MessageContainer> {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
        return Promise { seal in
            seal.fulfill(Response(proc: request.process))
        }
    }
    
    /// The corelocation manager is initiated here.
    /// If the user did not give permission or the sensor is disabled a rejection promise is
    /// returned.
    /// - parameter request: a Request object
    /// - Returns:
    /// a Promise with a MessageContainer
    func startReceivingLocationChanges(request: Request) -> Promise<MessageContainer> {
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 200.0
        self.locationManager.delegate = self
        
        return Promise { seal in
            seal.fulfill(Response(proc: request.process))
        }
    }
    
    private func enableLocationServices(status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            self.uiRegistry.tx(request: Request(proc: Task.mainView(.locationDisabled)))
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let recent = locations.last
        delegate?.locationChanged(latitude: Float(recent!.coordinate.latitude), longitude: Float(recent!.coordinate.longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        enableLocationServices(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
