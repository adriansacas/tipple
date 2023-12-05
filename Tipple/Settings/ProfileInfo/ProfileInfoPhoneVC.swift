//
//  ProfileInfoPhoneVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoPhoneVC: UITableViewController, UITextFieldDelegate, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        dismissKeyboardGesture()
        
        phoneTextField.borderStyle = .none
        phoneTextField.keyboardType = .numberPad
        
        phoneTextField.delegate = self
        
        setInitialPhone()
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
    
    func setInitialPhone() {
        if let phone = userProfileInfo?.phoneNumber {
            phoneTextField.text = phone
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let currentUser = currentUser,
              let newPhoneNumber = phoneTextField.text else {
            // Handle invalid input or user not authenticated
            return
        }

        if isValidPhoneNumber(newPhoneNumber) {
            let updatedData: [String: Any] = [
                "phoneNumber": newPhoneNumber
            ]

            firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)

            userProfileInfo?.phoneNumber = newPhoneNumber

            if let updatedProfileInfo = userProfileInfo {
                delegate?.didUpdateProfileInfo(updatedProfileInfo)
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            print("Invalid phone number entered.")
        }
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Remove hyphens from the phone number
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        if let _ = Int(cleanedPhoneNumber) {
            // The cleaned phone number can be converted to an integer
            return true
        } else {
            // The phone number contains non-numeric characters
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit the number of characters to 10
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        if newLength > 10 {
            return false
        }
        	
        return true
    }
}
