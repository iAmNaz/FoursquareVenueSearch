//
//  Venue.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 29/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

struct Venue: Codable {
    var name: String
    var location: Location
    enum CodingKeys: String, CodingKey {
        case name
        case location
    }
}
