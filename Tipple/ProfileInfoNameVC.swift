//
//  SettingsProfileInfoNameVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit

class ProfileInfoNameVC: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        TODO: Prepopulate the textfields with the data from firebase
        firstNameTextField.borderStyle = .none
        lastNameTextField.borderStyle = .none
        firstNameTextField.text = "Jane"
        lastNameTextField.text = "Doe"
    }

}
