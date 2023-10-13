//
//  ProfileInfoWeightVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit

class ProfileInfoWeightVC: UITableViewController {
    
    @IBOutlet weak var weightTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Populate the textField with firebase data
        weightTextField.borderStyle = .none
        weightTextField.text = "140"
    }
}
