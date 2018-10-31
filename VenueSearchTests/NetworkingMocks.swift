//
//  NetworkingMocks.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 29/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
@testable import VenueSearch

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}

class MockURLSession: URLSessionProtocol {
    
    var dataTask = MockURLSessionDataTask()
    var data: Data?
    var error: Error?
    var handler: DataTaskResult?
    
    private (set) var url: URL?
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        url = request.url
        
        self.handler = completionHandler
        
        return dataTask
    }
}
