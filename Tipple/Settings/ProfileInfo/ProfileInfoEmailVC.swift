//
//  ProfileInfoEmailVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoEmailVC: UITableViewController, ProfileInfoDelegateSettingVC {
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    var currentUser: User?
    
    @IBOutlet weak var currentEmailLabel: UILabel!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        dismissKeyboardGesture()
        
        currentEmailLabel.textColor = UIColor.gray
        newEmailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        passwordTextField.isSecureTextEntry = true;
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
                self.setEmailLabel()
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
    }
    
    func setEmailLabel() {
        guard let currentUser = currentUser else {
            return
        }
        
        currentEmailLabel.text = currentUser.email
    }
    
    // Add a gesture recognizer to dismiss the keyboard when the user
    // taps outside of any text field.
    func dismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let currentUser = currentUser,
              let currentEmail = currentEmailLabel.text,
              let password = passwordTextField.text,
              let newEmail = newEmailTextField.text,
              currentEmail != newEmail,
              isValidEmail(newEmail) else {
            // Handle invalid input
                  AlertUtils.showAlert(title: "Email Update Failed", message: "Please enter a valid email address and password.", viewController: self)
            return
        }
        
        // Re-authenticate the user with their current credentials
        // Then update the email address
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)

        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                // Handle reauthentication error
                print("Reauthentication failed: \(error.localizedDescription)")
                AlertUtils.showAlert(title: "Reauthentication Failed", message: error.localizedDescription, viewController: self)
            } else {
                // User is successfully reauthenticated
                // Verify the new email address first
                // Email will be updated in Firebase after user verifies through email
                currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                    if let error = error {
                        // Handle email verification error
                        print("Email verification failed: \(error.localizedDescription)")
                        AlertUtils.showAlert(title: "Email Verification Failed", message: error.localizedDescription, viewController: self)
                    } else {
                        AlertUtils.showNeedEmailConfirmationAlert(viewController: self)
                        self.deleteKeychain()
                    }
                }
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        if let regex = try? NSRegularExpression(pattern: emailRegex, options: .caseInsensitive) {
            return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
        }
        
        return false
    }
    
    //deletes login credentials on keychain
    func deleteKeychain(){
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "www.tipple.com"]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if (status == errSecSuccess || status == errSecItemNotFound) {
            print("successfully deleted off keychain")
        } else {
            print("something went wrong!!!")
        }
    }
}
