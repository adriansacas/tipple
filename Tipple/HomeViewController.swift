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
        
        controller.addAction(UIAlertAction(
            title: "Individual Session",
            style: .default
        ))
        
        controller.addAction(UIAlertAction(
            title: "Group Session",
            style: .default
        ))
        present(controller, animated: true)
    }
    
    @IBAction func joinSessionButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func previousSessionButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToLoginSegue", sender: nil)
        
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
