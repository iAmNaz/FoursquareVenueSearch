//
//  Errors.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

enum AppError: Error, Equatable {
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
            case (let .location(task1), let .location(task2)):
                return task1 == task2
            case (.generic(_), .location(_)):
                return false
            case (.location(_), .generic(_)):
                return false
            case (.generic(_), .generic(_)):
                return true
        }
    }
    
    case location(LocationError)
    enum LocationError {
        case notAuth
        case disabled
    }
    
    case generic(GenericError)
    enum GenericError {
        case undefined(message: String)
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .generic(.undefined(let message)):
            return message
        default:
            return "Error unknown"
        }
    }
}
