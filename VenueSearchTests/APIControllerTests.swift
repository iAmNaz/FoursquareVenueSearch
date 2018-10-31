//
//  APIControllerTests.swift
//  VenueSearchTests
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import XCTest
import DecouplerKit
import PromiseKit

@testable import VenueSearch

class APIControllerTests: XCTestCase {

    var session = MockURLSession()
    var data: Data!
    var dataFailure: Data!
    let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
    
    override func setUp() {
        PromiseKit.conf.Q.map = nil
        PromiseKit.conf.Q.return = nil
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
        api.tx(request: Request(proc: Task.api(.start)))
        
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
            api.tx(request: Request(proc: Task.api(.start)))
        
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
            api.tx(request: Request(proc: Task.api(.start)))
        
        XCTAssert(registry.currentTask == Task.mainView(.offline))
    }

    
    func testReloadListWhenReachabilityIsOnlineShouldBeMarkedFetching() {
        
        let expectation = XCTestExpectation(description: "Reload then fetching status")
        
        let registry = MockRegistry()
        let api = APIController(session: session)
            api.uiRegistry = registry

        let reachability = MockReachability()
            reachability!.currentConn = Connection.wifi

            api.reachability = reachability
            api.reloadList(latitude: 0, longitude: 0)
        
        registry.taskReceived = { (req) -> () in
            let task = req.process as! Task
            switch task {
            case .mainView(.fetching):
                expectation.fulfill()
            default:
                print("")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
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
        let expectation = XCTestExpectation(description: "Reload fail o dataTask error")
        
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask

        let api = APIController(session: session)
            api.uiRegistry = registry

        let reachability = MockReachability()
            reachability!.currentConn = Connection.wifi

            api.reachability = reachability
            api.reloadList(latitude: 0, longitude: 0)


        session.handler!(self.data, session.successHttpURLResponse(request: urlRequest), AppError.generic(.undefined(message: "Error")))
        
        registry.taskReceived = { (req) -> () in
            let task = req.process as! Task
            switch task {
            case .mainView(.fetchFailed):
                expectation.fulfill()
            default:
                print("")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testReloadListShouldFailWhenDataIsNil() {
        
        let expectation = XCTestExpectation(description: "Reload fail on nil data")
        
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
            session.dataTask = dataTask

        let api = APIController(session: session)
            api.uiRegistry = registry

        let reachability = MockReachability()
            reachability!.currentConn = Connection.wifi

            api.reachability = reachability
            api.reloadList(latitude: 0, longitude: 0)


        session.handler!(nil, session.successHttpURLResponse(request: urlRequest), nil)

        registry.taskReceived = { (req) -> () in
            let task = req.process as! Task
            switch task {
            case .mainView(.fetchFailed):
                expectation.fulfill()
            default:
                print("")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testReloadListShouldCompleteWhenOnlineWithValidData() {
        
        let expectation = XCTestExpectation(description: "Reload completes with data")
        
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
            session.dataTask = dataTask

        let api = APIController(session: session)
            api.uiRegistry = registry

        let reachability = MockReachability()
            reachability!.currentConn = Connection.wifi

            api.reachability = reachability
            api.reloadList(latitude: 0, longitude: 0)

        session.handler!(self.data, session.successHttpURLResponse(request: urlRequest), nil)

        registry.taskReceived = { (req) -> () in
            let task = req.process as! Task
            switch task {
            case .mainView(.displayData):
                expectation.fulfill()
            default:
                print("")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testReloadListShouldDisplay10Venues() {

        let expectation = XCTestExpectation(description: "Fetch 10 Venues")

        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
            session.dataTask = dataTask

        let api = APIController(session: session)
            api.uiRegistry = registry

        let reachability = MockReachability()
            reachability!.currentConn = Connection.wifi

            api.reachability = reachability
            api.reloadList(latitude: 0, longitude: 0)

        session.handler!(self.data, session.successHttpURLResponse(request: urlRequest), nil)

        registry.taskReceived = { (req) -> () in
            let task = req.process as! Task
            switch task {
            case .mainView(.displayData):
                let vms = req.body() as [VenueViewModel]
                XCTAssert(vms.count == 10)
                expectation.fulfill()
            default:
                print("")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    
    func testReloadListShouldFailWhenOnlineButWithHttpError() {
        let expectation = XCTestExpectation(description: "Reload fail on HTTP Error")
        let registry = MockRegistry()
        let dataTask = MockURLSessionDataTask()
        session.dataTask = dataTask
        
        let api = APIController(session: session)
            api.uiRegistry = registry
        
        let reachability = MockReachability()
            reachability!.currentConn = Connection.wifi
        
            api.reachability = reachability
            api.reloadList(latitude: 0, longitude: 0)
        
        session.handler!(self.dataFailure, session.successHttpURLResponse(request: urlRequest), nil)
        
        registry.taskReceived = { (req) -> () in
            let task = req.process as! Task
            switch task {
            case .mainView(.fetchFailed):
                expectation.fulfill()
            default:
                print("")
            }
        }
        wait(for: [expectation], timeout: 5.0)
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
