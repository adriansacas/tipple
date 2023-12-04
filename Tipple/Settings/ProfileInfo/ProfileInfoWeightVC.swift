//
//  ProfileInfoWeightVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoWeightVC: UITableViewController, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var weightTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        dismissKeyboardGesture()
        
        weightTextField.borderStyle = .none
        weightTextField.keyboardType = .numberPad
        
        setInitialWeight()
    }
    
    func getCurrentUser() {
        AuthenticationManager.shared.getCurrentUser(viewController: self) { user, error in
            if let error = error {
                // Errors are handled in AuthenticationManager
                print("Error retrieving user: \(error.localizedDescription)")
            } else if let user = user {
                // Successfully retrieved the currentUser
                self.currentUser = user
                // Do anything that needs the currentUser
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
    
    func setInitialWeight() {
        if let weight = userProfileInfo?.weight {
            weightTextField.text = String(weight)
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let currentUser = currentUser,
              let weightText = weightTextField.text,
              let weight = Int(weightText) else {
            // Handle invalid input or user not authenticated
            return
        }

        let updatedData: [String: Any] = [
            "weight": weight
        ]

        firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)

        userProfileInfo?.weight = weight

        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }

        navigationController?.popViewController(animated: true)
    }
    
}
