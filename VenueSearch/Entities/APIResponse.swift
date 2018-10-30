//
//  APIResponse.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 29/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

struct APIResponse: Codable {
    var meta: Meta
    var response: ResponseBody
    
    enum CodingKeys: String, CodingKey {
        case meta
        case response
    }
}
