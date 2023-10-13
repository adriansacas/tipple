//
//  ProfileInfoEmailVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit

class ProfileInfoEmailVC: UITableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: populate textfield with firebase data
        emailTextField.borderStyle = .none
        emailTextField.text = "jane@doe.com"
    }
}
