//
//  APIControllerTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
import DecouplerKit

@testable import VenueSearch

class APIControllerTests: XCTestCase {

    var session = MockURLSession()
    var data: Data!
    var dataFailure: Data!
    
    override func setUp() {
        do {
            self.data = try loadDataFromJSONFile(name: "venues")
            self.dataFailure = try loadDataFromJSONFile(name: "venues-fail")
        } catch {
            print("Loading data error: \(error.localizedDescription)")
        }
    }

    override func tearDown() {}
    
    func testSampleDataLoaded() {
        XCTAssertNotNil(self.data)
    }
    
    func testReloadListWhenReachabilityIsOfflineShouldBeMarkedOffline() {
        let registry = MockRegistry()
        let api = APIController(session: session)
            api.uiRegistry = registry
        
        let reachability = MockReachability()
            reachability!.currentConn = Connection.none
        
            api.reachability = reachability
        
            api.reloadList(latitude: 0, longitude: 0)
        
        XCTAssert(registry.currentTask == Task.mainView(.offline))
    }
    
    func testStartMonitoringWhenUnreachableShouldBeMarkedOffline() {
        let registry = MockRegistry()
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.none
        
        api.reachability = reachability
        api.startMonitoring()
        
        let block = reachability?.whenUnreachable
            block!(reachability!)
        XCTAssert(registry.currentTask == Task.mainView(.offline))
    }

    func testStartMonitoringWhenReachableShouldBeMarkedOnline() {
        let registry = MockRegistry()
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
            reachability!.currentConn = Connection.cellular
        
        api.reachability = reachability
        api.startMonitoring()
        
        let block = reachability?.whenReachable
        block!(reachability!)
        
        XCTAssert(registry.currentTask == Task.mainView(.online))
    }
    
    func testStartMonitoringWhenStartNotifierThrowsException() {
        let registry = MockRegistry()
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.cellular
        reachability!.shouldThrow = true
        api.reachability = reachability
        api.startMonitoring()
        
        XCTAssert(registry.currentTask == Task.mainView(.offline))
    }

    
    func testReloadListWhenReachabilityIsOnlineShouldBeMarkedFetching() {
        let registry = MockRegistry()
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        XCTAssert(registry.currentTask == Task.mainView(.fetching))
    }

    func testReloadListWhenCalledShouldResumeDataTask() {
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        XCTAssert(dataTask.resumeWasCalled == true)
    }
    
    func testReloadListShouldHaveCorrectUrl() {
        let url = "\(venueSearchEndPoint)?ll=0.0,0.0&radius=2000&client_id=\(clientId)&client_secret=\(clientSecret)&v=20181001"
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
            api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        XCTAssert(session.url?.absoluteString == url)
    }
    
    func testReloadListShouldFailWhenDataTaskEncountersError() {
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        session.handler!(self.data, session.successHttpURLResponse(request: urlRequest), AppError.generic(.undefined(message: "Error")))
        
        XCTAssert(registry.currentTask == Task.mainView(.fetchFailed))
    }
    
    func testReloadListShouldFailWhenDataIsNil() {
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        session.handler!(nil, session.successHttpURLResponse(request: urlRequest), nil)
        
        XCTAssert(registry.currentTask == Task.mainView(.fetchFailed))
    }
    
    func testReloadListShouldCompleteWhenOnlineWithValidData() {
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        session.handler!(self.data, session.successHttpURLResponse(request: urlRequest), nil)
        
        XCTAssert(registry.currentTask == Task.mainView(.displayData))
    }
    
    func testReloadListShouldDisplay10Venues() {
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        session.handler!(self.data, session.successHttpURLResponse(request: urlRequest), nil)
        let vms = registry.request.body() as [VenueViewModel]
        XCTAssert(vms.count == 10)
    }

    
    func testReloadListShouldFailWhenOnlineButWithHttpError() {
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
        api.uiRegistry = registry
        
        let reachability = MockReachability()
        reachability!.currentConn = Connection.wifi
        
        api.reachability = reachability
        
        api.reloadList(latitude: 0, longitude: 0)
        
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        session.handler!(self.dataFailure, session.successHttpURLResponse(request: urlRequest), nil)
        
        XCTAssert(registry.currentTask == Task.mainView(.fetchFailed))
    }
    
    func testLocationDelegateImplementedShouldDisplayData() {
        let dataTask = MockURLSessionDataTask()
            session.dataTask = dataTask
        
        let api = MockAPIController(session: session)
            api.locationChanged(latitude: 0, longitude: 0)
        
        XCTAssert(api.reloadCalled)
    }
    
    func testAPIControllerRespondsWithReceivedTask() {
        let registry = ResponderRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: URLSession(configuration: .default))
            api.uiRegistry = registry
            registry.register(inputHandler: api)
        let promise = registry.tx(request: Request(proc: Task.api(.start)))
        let response = promise.value as! Response
        let task = response.process as! Task
        XCTAssertTrue(task == Task.api(.start))
    }
}
