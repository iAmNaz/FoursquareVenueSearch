//
//  VenueViewModel.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

struct VenueViewModel {
    private (set) var venue: Venue!
    
    var name: String {
        get {
            return venue.name
        }
    }
    
    var distance: String {
        get {
            return "\(venue.location.distance)"
        }
    }
    
    var address: String {
        get {
            return venue.location.address != nil ? "\(venue.location.address!)" : ""
        }
    }
    
    init(venue: Venue) {
        self.venue = venue
    }
}
