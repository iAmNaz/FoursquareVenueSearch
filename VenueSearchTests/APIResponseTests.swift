//
//  APIResponseTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
@testable import VenueSearch

class APIResponseTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAPIResponseShouldLoadJsonWithNoError() {
        let data = try! loadDataFromJSONFile(name: "venues")
        let response = try! decodeJson(data: data!)
        XCTAssertEqual(response.meta.code, 200)
        XCTAssertEqual(response.response.venues.count, 10)
    }
}
