//
//  APIController.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import DecouplerKit
import PromiseKit

let venueSearchEndPoint = "https://api.foursquare.com/v2/venues/search"
let clientId = "DSXABGDSRON0OEK0YXWB3CSUNBJ5ZY4QH2LJWWR13H1M0NIR"
let clientSecret = "SM1Z1N4WNVBCZ1I22XNFGOTSPFQFBOCEQ3IL00UJSISPMDWG"

class APIController: NSObject, URLSessionDelegate, Interface {
    var uiRegistry: ResponderRegistry!
    
    var reachability: Reachability!
    
    private var session: URLSessionProtocol!
    
    private var currentLocation: (latitude: Float, longitude: Float)!
    
    init(session: URLSessionProtocol) {
        super.init()
        self.reachability = Reachability()
        self.session = session
    }
    
    func tx(request: Request) -> Promise<MessageContainer> {
        let task = request.process as! Task
        switch task {
        case .api(.start):
            startMonitoring()
            return Promise { seal in
                seal.fulfill(Response(proc: task))
            }
        default:
            return Promise { seal in
                seal.reject(AppError.generic(.undefined(message: NSLocalizedString("APIController is unable to handle the task", comment: ""))))
            }
        }
    }
    
    func reloadList(latitude: Float, longitude: Float) {
        
        if !reachable() {
            markOffline()
            return
        }
        
        currentLocation = (latitude: latitude, longitude: longitude)
        
        let request = createVenueSearchRequest(latitude: latitude, longitude: longitude)
        
        self.uiRegistry.tx(request: Request(proc: Task.mainView(.fetching)))
        
        let task = session.dataTask(with: request, completionHandler: {data, response, err -> Void in
            
            if err != nil {
                self.uiRegistry.tx(request: Request(proc: Task.mainView(.fetchFailed)))
                return
            }
            
            if let inData = data {
                do {
                    let response = try decodeJson(data: inData)
                    self.uiRegistry.tx(request: Request(proc: Task.mainView(.fetchCompleted)))
                    
                    if response.meta.code == 200 {
                        
                        var venuesVM = [VenueViewModel]()
                        
                        for venue in response.response.venues {
                            let vm = VenueViewModel(venue: venue)
                                venuesVM.append(vm)
                        }
                        self.uiRegistry.tx(request: Request(proc: Task.mainView(.displayData), body: venuesVM))
                    } else{
                        self.uiRegistry.tx(request: Request(proc: Task.mainView(.fetchFailed)))
                    }
                } catch {
                    print("error \(error)")
                    self.uiRegistry.tx(request: Request(proc: Task.mainView(.fetchFailed)))
                }
            }else{
                self.uiRegistry.tx(request: Request(proc: Task.mainView(.fetchFailed)))
            }
        })
        
        task.resume()
    }
    
    private func createVenueSearchRequest(latitude: Float, longitude: Float) -> URLRequest {
        
        let url = "\(venueSearchEndPoint)?ll=\(latitude),\(longitude)&radius=2000&client_id=\(clientId)&client_secret=\(clientSecret)&v=20181001"
        
        var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func startMonitoring() {
        reachability.whenReachable = { reachability in
            self.markOnline()
        }
        reachability.whenUnreachable = { _ in
            self.markOffline()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            self.markOffline()
        }
    }
    
    func reachable() -> Bool {
        return reachability.connection() != .none
    }
    
    private func markOnline() {
        self.uiRegistry.tx(request: Request(proc: Task.location(.online)))
        self.uiRegistry.tx(request: Request(proc: Task.mainView(.online)))
    }
    
    private func markOffline() {
        self.uiRegistry.tx(request: Request(proc: Task.mainView(.offline)))
    }
}

extension APIController: LocationControllerDelegate {
    func locationChanged(latitude: Float, longitude: Float) {
        reloadList(latitude: latitude, longitude: longitude)
    }
}

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping URLSessionProtocol.DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
