//
//  SignupViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: Cannot show Automatic Strong Passwords for app bundleID: CS371L.Tipple due to error: iCloud Keychain is disabled
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    @IBAction func signupButtonPressed(_ sender: Any) {
        
        if(passwordTextField.text! != confirmPasswordTextField.text!){
            
            self.errorStatus.text = "Confirm password does not match password"
        } else {
            Auth.auth().createUser(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.errorStatus.text = "\(error.localizedDescription)"
                } else {
                    self.errorStatus.text = ""
                }
                
                //log in new user immediately
                if error == nil {
                    Auth.auth().signIn(withEmail: self.emailAddressTextField.text!, password: self.passwordTextField.text!)
                    self.performSegue(withIdentifier: "signupToHomeSegue", sender: nil)
                 }
            }
            
        }
        
    }
    
    
    @IBAction func loginTextButtonPressed(_ sender: Any) {
            performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
