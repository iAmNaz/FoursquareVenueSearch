//
//  Venue.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 29/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

struct Location: Codable {
    var lat: Float
    var lng: Float
    var distance: Float
    var address: String?
    enum CodingKeys: String, CodingKey {
        case lat
        case lng
        case distance
        case address
    }
}
