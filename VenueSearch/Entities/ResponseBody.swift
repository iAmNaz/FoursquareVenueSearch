//
//  Response.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 29/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

struct ResponseBody: Codable {
    var venues: [Venue]
    enum CodingKeys: String, CodingKey {
        case venues
    }
}
