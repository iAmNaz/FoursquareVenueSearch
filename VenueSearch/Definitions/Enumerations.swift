//
//  Enumerations.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import DecouplerKit

let keyLocationController = "LocationController"
let keyMainViewController = "MainViewController"
let keyAPIController = "APIController"

enum Task: Processable, Equatable {
    var key: String {
        get {
            switch self {
            case .location( _):
                return keyLocationController
            case .mainView(_):
                return keyMainViewController
            case .api(_):
                return keyAPIController
            }
        }
    }
    
    ///LocationController
    case location(LocationController)
    enum LocationController {
        case start
    }
    
    ///APIController
    case api(APIController)
    enum APIController {
        case start
        case getVenues
    }
    
    ///MainViewController
    case mainView(MainViewController)
    enum MainViewController {
        case online
        case offline
        case fetching
        case fetchFailed
        case fetchCompleted
        case displayData
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        switch (lhs, rhs) {
            case (let .location(task1), let .location(task2)):
                return task1 == task2
            case (let .mainView(task1), let .mainView(task2)):
                return task1 == task2
            case (let .api(task1), let .api(task2)):
                return task1 == task2
            case (.mainView(_), .location(_)):
                return false
            case (.location(_), .mainView(_)):
                return false
            case (.api(_), .location(_)):
                return false
            case (.api(_), .mainView(_)):
                return false
            case (.mainView(_), .api(_)):
                return false
            case (.location(_), .api(_)):
                return false
        }
    }
}

