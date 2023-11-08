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
    
    @IBOutlet weak var currentEmailLabel: UILabel!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardGesture()
        
        currentEmailLabel.textColor = UIColor.gray
        newEmailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        passwordTextField.isSecureTextEntry = true;
        
        if let userEmail = Auth.auth().currentUser?.email {
            currentEmailLabel.text = userEmail
        }
    }
    
    // Add a gesture recognizer to dismiss the keyboard when the user
    // taps outside of any text field.
    func dismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let currentEmail = currentEmailLabel.text,
              let password = passwordTextField.text,
              let newEmail = newEmailTextField.text else {
            // Handle invalid input
            return
        }

        if isValidEmail(newEmail) {
            print("Valid email address")
        } else {
            print("Invalid email address")
        }

        if currentEmail != newEmail {
            // Re-authenticate the user with their current credentials
            // Then update the email address
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)

            user?.reauthenticate(with: credential) { result, error in
                if let error = error {
                    // Handle reauthentication error
                    print("Reauthentication failed: \(error.localizedDescription)")
                    AlertUtils.showAlert(title: "Reauthentication Failed", message: error.localizedDescription, viewController: self)
                } else {
                    // User is successfully reauthenticated
                    // Verify the new email address first
                    user?.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                        if let error = error {
                            // Handle email verification error
                            print("Email verification failed: \(error.localizedDescription)")
                            AlertUtils.showAlert(title: "Email Verification Failed", message: error.localizedDescription, viewController: self)
                        } else {
                            // Email address verified, now update the email
                            user?.updateEmail(to: newEmail) { error in
                                if let error = error {
                                    // Handle email update error
                                    print("Email update failed: \(error.localizedDescription)")
                                    AlertUtils.showAlert(title: "Email Update Failed", message: error.localizedDescription, viewController: self)
                                } else {
                                    // Email address updated successfully
                                    print("Email updated to: \(newEmail)")
                                    // Update the email in your Firestore document here
                                    if let updatedProfileInfo = self.userProfileInfo {
                                        self.delegate?.didUpdateProfileInfo(updatedProfileInfo)
                                    }
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            print("New email is the same as the current email")
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        if let regex = try? NSRegularExpression(pattern: emailRegex, options: .caseInsensitive) {
            return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
        }
        
        return false
    }
}
