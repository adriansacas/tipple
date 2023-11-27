//
//  LoginViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit
import FirebaseAuth

// Get a reference to the global user defaults object
let defaults = UserDefaults.standard

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self

        // Do any additional setup after loading the view.
        passwordTextField.isSecureTextEntry = true;
        
        //TODO: comment out for the demo presentation/final project
        //check if user wants to stay logged in
        //if(defaults.bool(forKey: "tippleStayLoggedIn") == true){
            
            // Auto login user if they didn't log out
            Auth.auth().addStateDidChangeListener() { (auth, user) in
                if user != nil {
                    self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                }
            }
        //}
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if(emailAddressTextField.text! == "" || passwordTextField.text! == ""){
            AlertUtils.showAlert(title: "Incomplete Fields", message: "Complete all fields to login.", viewController: self)
        } else {
            Auth.auth().signIn(withEmail: emailAddressTextField.text! , password: passwordTextField.text!) {
                (authResult, error) in
                if (error as NSError?) != nil {
                    AlertUtils.showAlert(title: "Login Error", message: "Email may not exist or password is incorrect.", viewController: self)
                } else {
                    //TODO: take out for demo presentation/final submission
                    //save that the user wants to stay logged in
//                    defaults.set(true, forKey: "tippleStayLoggedIn")
                    self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                }
            }
        }
    }
    
    @IBAction func signupTextButtonPressed(_ sender: Any){
        performSegue(withIdentifier: "signupSegue", sender: nil)
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
