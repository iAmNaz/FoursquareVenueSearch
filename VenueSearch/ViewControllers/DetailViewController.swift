//
//  DetailViewController.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    var venue: VenueViewModel!
    
    let noInfo = NSLocalizedString("No info available", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = noInfo
        addressLabel.text = noInfo
        
        if let info = venue {
            nameLabel.text = info.name + "\n"
            
            if !info.address.isEmpty {
                addressLabel.text = NSLocalizedString("Address:\n\n", comment: "") + info.address
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
