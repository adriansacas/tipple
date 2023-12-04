//
//  SettingsProfileInfoNameVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoNameVC: UITableViewController, ProfileInfoDelegateSettingVC {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        dismissKeyboardGesture()
        
        firstNameTextField.borderStyle = .none
        lastNameTextField.borderStyle = .none
        
        firstNameTextField.text = userProfileInfo?.firstName
        lastNameTextField.text = userProfileInfo?.lastName
    }
    
    func getCurrentUser() {
        AuthenticationManager.shared.getCurrentUser(viewController: self) { user, error in
            if let error = error {
                // Errors are handled in AuthenticationManager
                print("Error retrieving user: \(error.localizedDescription)")
            } else if let user = user {
                // Successfully retrieved the currentUser
                self.currentUser = user
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
    }
    
    // Add a gesture recognizer to dismiss the keyboard when the user
    // taps outside of any text field.
    func dismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    @IBAction func saveChanges(_ sender: Any) {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let currentUser = currentUser else {
            // Handle invalid input or user not authenticated
            return
        }
        
        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName
        ]
        
        firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)
        
        userProfileInfo?.firstName = firstName
        userProfileInfo?.lastName = lastName
        
        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
