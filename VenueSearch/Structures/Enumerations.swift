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

enum Task: Processable, Equatable {
    var key: String {
        get {
            switch self {
            case .location( _):
                return keyLocationController
            }
        }
    }
    
    case location(LocationController)
    
    enum LocationController {
        case start
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        switch (lhs, rhs) {
        case (let .location(task1), let .location(task2)):
            return task1 == task2
        
        }
    }
    
}

