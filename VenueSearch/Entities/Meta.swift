//
//  Meta.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 29/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

struct Meta: Codable {
    var code: Int
    enum CodingKeys: String, CodingKey {
        case code
    }
}
