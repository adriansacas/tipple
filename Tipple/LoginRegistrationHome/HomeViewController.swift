//
//  HomeViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startSessionButtonPressed(_ sender: Any) {
        
        let controller = UIAlertController(
            title: "Choose Session Type",
            message: "Choose the session you want to start",
            preferredStyle: .alert
        )
        
        let individualSessionAction = UIAlertAction(
            title: "Individual Session",
            style: .default
        ) { (action) in
            self.performSegue(withIdentifier: "individualToQASegue", sender: self)
        }

        controller.addAction(individualSessionAction)
        
        controller.addAction(UIAlertAction(
            title: "Group Session",
            style: .default
        ) { (action) in
            self.performSegue(withIdentifier: "groupSessionSegue", sender: self)
        }
                             
        )
        present(controller, animated: true)
    }
    
    @IBAction func joinSessionButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func previousSessionButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToPrevSession", sender: nil)
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToLoginSegue", sender: nil)
    }

}
