//
//  Convenience.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

func decodeJson(data: Data) throws -> APIResponse {
    do {
        return try JSONDecoder().decode(APIResponse.self, from: data)
    } catch {
        throw error
    }
}

func loadDataFromJSONFile(name: String) throws -> Data? {
    if let path = Bundle.main.path(forResource: name, ofType: "json") {
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        } catch {
            throw error
        }
    }
    return nil
}

