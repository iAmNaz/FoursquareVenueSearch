//
//  ViewController.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 26/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit
import DecouplerKit
import PromiseKit

class MainViewController: UIViewController, Interface {
    var registry: ResponderRegistry!
    var venues = [VenueViewModel]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    func tx(request: Request) -> Promise<MessageContainer> {
        
        let task = request.process as! Task
        
        switch task {
        case .mainView(.online):
            self.online()
        case .mainView(.offline):
            self.offline()
        case .mainView(.fetching):
            self.loading()
        case .mainView(.fetchFailed):
            self.networkIndicator(show: false)
        case .mainView(.fetchCompleted):
            self.networkingComplete()
        case .mainView(.displayData):
            let venues = request.body() as [VenueViewModel]
            self.displayVenues(venues: venues)
        case .mainView(.locationDisabled):
            askPermission()
        default:
            return Promise { seal in
                seal.reject(AppError.generic(.undefined(message: NSLocalizedString("LocationController is unable to handle the task", comment: ""))))
            }
        }
        
        return Promise { seal in
            seal.fulfill(Response(proc: task))
        }
    }
 
    //MARK: UI States
    func online() {
        self.statusLabel.isHidden = true
        tableView.isHidden = true
    }
    
    func offline() {
        self.statusLabel.isHidden = false
        self.statusLabel.text = NSLocalizedString("You are not connected to the internet.", comment: "")
        networkIndicator(show: false)
        tableView.isHidden = true
    }
    
    func loading() {
        self.statusLabel.isHidden = false
        self.statusLabel.text = NSLocalizedString("Loading venues...", comment: "")
        networkIndicator(show: true)
        tableView.isHidden = true
    }
    
    func networkingComplete() {
        self.statusLabel.isHidden = true
        networkIndicator(show: false)
    }
    
    func displayVenues(venues: [VenueViewModel]) {
        networkIndicator(show: false)
        self.venues = venues
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func networkIndicator(show: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Venue Search"
        
        registry.tx(request: Request(proc: Task.api(.start)))
        registry.tx(request: Request(proc: Task.location(.start)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVenueDetail" {
            let vc = segue.destination as! DetailViewController
            vc.venue = self.venues[tableView.indexPathForSelectedRow!.row]
        }
    }
}

//MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        let venue = venues[indexPath.row]
        cell.detailTextLabel?.text = venue.distance
        cell.textLabel?.text = venue.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
}

