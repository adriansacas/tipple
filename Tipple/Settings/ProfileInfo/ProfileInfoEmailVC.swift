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
              let newEmail = newEmailTextField.text,
              currentEmail != newEmail,
              isValidEmail(newEmail) else {
            // Handle invalid input
                  AlertUtils.showAlert(title: "Email Update Failed", message: "Please enter a valid email address and password.", viewController: self)
            return
        }
        
        // Re-authenticate the user with their current credentials
        // Then update the email address
        let user = Auth.auth().currentUser
        print(user?.isEmailVerified ?? "NA")
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)

        user?.reauthenticate(with: credential) { result, error in
            if let error = error {
                // Handle reauthentication error
                print("Reauthentication failed: \(error.localizedDescription)")
                AlertUtils.showAlert(title: "Reauthentication Failed", message: error.localizedDescription, viewController: self)
            } else {
                // User is successfully reauthenticated
                // Verify the new email address first
                // Email will be updated in Firebase after user verifies through email
                user?.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                    if let error = error {
                        // Handle email verification error
                        print("Email verification failed: \(error.localizedDescription)")
                        AlertUtils.showAlert(title: "Email Verification Failed", message: error.localizedDescription, viewController: self)
                    } else {
                        let alertController = UIAlertController(
                            title: "Email Update",
                            message: "Check your inbox to confirm your new email",
                            preferredStyle: .alert
                        )
                        
                        let action = UIAlertAction(title: "OK", style: .default) { (_) in
                            // logout user
                            defaults.set(false, forKey: "tippleStayLoggedIn")
                            self.performSegue(withIdentifier: "LoginPage", sender: nil)
                        }
                        
                        alertController.addAction(action)
                        
                        self.present(alertController, animated: true)
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
}
