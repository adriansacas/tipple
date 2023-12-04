//
//  ProfileInfoHeightVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoHeightVC: UITableViewController, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var feetTextField: UITextField!
    @IBOutlet weak var inchesTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        dismissKeyboardGesture()
        
        feetTextField.borderStyle = .none
        inchesTextField.borderStyle  = .none
        
        feetTextField.keyboardType = .numberPad
        inchesTextField.keyboardType = .numberPad
        
        setInitialHeight()
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
    
    func setInitialHeight() {
        if let heightFeet = userProfileInfo?.heightFeet {
            feetTextField.text = String(heightFeet)
        }
        
        if let heightInches = userProfileInfo?.heightInches {
            inchesTextField.text = String(heightInches)
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let currentUser = currentUser,
              let feetText = feetTextField.text,
              let inchesText = inchesTextField.text else {
            // Handle user not authenticated
            return
        }
        
        if let feet = Int(feetText), let inches = Int(inchesText) {
            if inches > 12 {
                AlertUtils.showAlert(title: "Invalid Height", message: "Inches cannot be greater than 12.", viewController: self)
                return
            }
            
            if inches < 0 || feet < 0 {
                AlertUtils.showAlert(title: "Invalid Height", message: "No negative values allowed.", viewController: self)
                return
            }
            
            let updatedData: [String: Any] = [
                "heightFeet": feet,
                "heightInches": inches
            ]
            
            firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)
            
            userProfileInfo?.heightFeet = feet
            userProfileInfo?.heightInches = inches
            
            if let updatedProfileInfo = userProfileInfo {
                delegate?.didUpdateProfileInfo(updatedProfileInfo)
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            AlertUtils.showAlert(title: "Invalid Height", message: "Please enter a valid number.", viewController: self)
        }
    }
    
}
