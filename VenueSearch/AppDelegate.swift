//
//  AppDelegate.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import Dip
import DecouplerKit
import CoreLocation

extension MainViewController: StoryboardInstantiatable { }

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let container = DependencyContainer { container in
        
        container.register(.singleton) { ResponderRegistry() as ResponderRegistry }
        
        container.register(storyboardType: MainViewController.self, tag: "MainViewController")
            .resolvingProperties { container, controller in
                let registry = try container.resolve() as ResponderRegistry
                controller.registry = registry
                registry.register(inputHandler: controller)
        }

        DependencyContainer.uiContainers = [container]
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let registry = try! container.resolve() as ResponderRegistry
        let locationManager = CLLocationManager()
        let locationController = LocationController(locationManager: locationManager)
            locationController.uiRegistry = registry
        
        let apiController = APIController(session: URLSession(configuration: .default))
            apiController.uiRegistry = registry
            locationController.delegate = apiController
        
        registry.register(inputHandler: locationController, withKey: keyLocationController)
        registry.register(inputHandler: apiController)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
