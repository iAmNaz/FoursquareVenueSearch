//
//  ViewModelTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
@testable import VenueSearch

class ViewModelTests: XCTestCase {

    var viewModel: VenueViewModel!
    let venueName = "Team B"
    override func setUp() {
        let venue = Venue(name: venueName, location: Location(lat: 0, lng: 0, distance: 50.0, address: "LA"))
        viewModel = VenueViewModel(venue: venue)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewModelShouldReturnCorrectNameWhenSet() {
        XCTAssertEqual(viewModel.name, venueName)
    }

    func testViewModelShouldReturnCorrectDistanceWhenSet() {
        XCTAssertEqual(viewModel.distance, "50.0")
    }
    
    func testViewModelShouldReturnCorrectAddressWhenSet() {
        XCTAssertEqual(viewModel.address, "LA")
    }
    
    func testViewModelShouldReturnEmptyAddressWhenEmpty() {
        let venue = Venue(name: venueName, location: Location(lat: 0, lng: 0, distance: 50.0, address: ""))
        let aViewModel = VenueViewModel(venue: venue)
        XCTAssertEqual(aViewModel.address, "")
    }
}
