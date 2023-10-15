//
//  SettingsProfileInfoNameVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoNameVC: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    let firestoreManager = FirestoreManager.shared
    var userProfileInfo: ProfileInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.borderStyle = .none
        lastNameTextField.borderStyle = .none
        firstNameTextField.text = userProfileInfo?.firstName
        lastNameTextField.text = userProfileInfo?.lastName
    }

    @IBAction func saveChanges(_ sender: Any) {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let userID = Auth.auth().currentUser?.uid else {
            // Handle invalid input or user not authenticated
            return
        }
        
        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName
        ]
        
        FirestoreManager.shared.updateUserDocument(userID: userID, updatedData: updatedData)
        
        userProfileInfo?.firstName = firstName
        userProfileInfo?.lastName = lastName
        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
