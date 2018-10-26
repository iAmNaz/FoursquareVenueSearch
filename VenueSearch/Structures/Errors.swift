//
//  Errors.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

enum AppError: Error {

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
