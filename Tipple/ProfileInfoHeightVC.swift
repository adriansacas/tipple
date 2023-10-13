//
//  ProfileInfoHeightVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit

class ProfileInfoHeightVC: UITableViewController {
    
    @IBOutlet weak var feetTextField: UITextField!
    @IBOutlet weak var inchesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        TODO: Populate the textfields with firebase data
        feetTextField.borderStyle = .none
        inchesTextField.borderStyle  = .none
        feetTextField.text = "5"
        inchesTextField.text = "4"
    }
}
