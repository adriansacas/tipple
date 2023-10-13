//
//  ProfileInfoPhoneVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit

class ProfileInfoPhoneVC: UITableViewController {
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: populate the textfield with firebase data
        phoneTextField.borderStyle = .none
        phoneTextField.text = "512-655-9922"
    }
}
