//
//  MainViewController+Settings.swift
//  VenueSearch
//
//  Created by Nazario Mariano on 30/10/2018.
//  Copyright © 2018 Nazario Mariano. All rights reserved.
//

import UIKit

//MARK: Location Permission Settings
extension MainViewController {
    func goToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func askPermission() {
        let alertController = UIAlertController(title: NSLocalizedString("Location services needed", comment: ""), message: NSLocalizedString("Venue Search will need the location services enabled to be able to make venue suggestions.", comment: ""), preferredStyle: .alert)
        
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("Go to Setting", comment: ""), style: .default) { (_) -> Void in
            self.goToSettings()
        }
        
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default){ (_) -> Void in
            
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
