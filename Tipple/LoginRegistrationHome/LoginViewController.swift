//
//  LoginViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit
import FirebaseAuth
import LocalAuthentication

// Get a reference to the global user defaults object
let defaults = UserDefaults.standard

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var context = LAContext()
    
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
            //Auth.auth().addStateDidChangeListener() { (auth, user) in
                //if user != nil {
                    //self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                //}
            //}
        //}
        
        
        //testing facial recognition
//        var error: NSError?
//        var canEvaluateBool = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
//        
//        print("canEvaluatePolicy? \(canEvaluateBool)")
//        print("error message: \(error?.localizedDescription)")
        
        
        
        
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
    
    
    @IBAction func faceIDLoginButtonPressed(_ sender: Any) {
        
        let context = LAContext()
        
        var error: NSError?
        
        if(context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)){
            
            print("faceID allowed")
            let reason = "Log in to app"
        
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, 
                                   localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    
                    if success {
                        //login with appropriate email and password, then segue into home page
                        print("authentication possible and should log in successfully")
                        
                        
                        //TODO: figure out how to save and retrieve email and password to keychain
                        //testing with account that's already been made
                        Auth.auth().signIn(withEmail: "test@tipple.com" , password: "testing") {
                            (authResult, error) in
                            if (error as NSError?) != nil {
                                AlertUtils.showAlert(title: "Login Error", message: "Email may not exist or password is incorrect.", viewController: self!)
                            } else {
                                self?.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                            }
                        }
                        
                        
                        
                        
                    } else {
                        
                        print("authentication possible but NO MATCH")
                        let alert = UIAlertController(
                            title: "Authentication failed",
                            message: "You could not be verfied, please try again",
                            preferredStyle: .alert
                        )
                        
                        let action = UIAlertAction(
                            title: "OK",
                            style: .default)
                        
                        action.setValue(UIColor(hex: "#3634A3"), forKey:"titleTextColor")
                        alert.addAction(action)
                        
                        self?.present(alert, animated: true)
                        
                    }
                    
                }
                
            }
            
            
            
            
            
            
            
            
        } else {
            let alert = UIAlertController(
                title: "Biometry unavailable",
                message: "Your device is not configured for biometric authentication.",
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(
                title: "OK",
                style: .default)
            
            action.setValue(UIColor(hex: "#3634A3"), forKey:"titleTextColor")
            alert.addAction(action)
            
            present(alert, animated: true)
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
