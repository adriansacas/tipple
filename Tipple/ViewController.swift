//
//  ViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/10/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func goLoginButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginRegistrationSegue", sender: nil)
    }
    
}

