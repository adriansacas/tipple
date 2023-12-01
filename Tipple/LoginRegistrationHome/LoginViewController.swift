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
        //Auto login user if they didn't log out
        Auth.auth().addStateDidChangeListener() { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
            }
        }
        
        //TODO: for keychain cleaning purposes
        //print("deleting keychain credentials")
        //deleteKeychain()
        
    }
    
    //DEMO/TESTING purposes: for deleting key on xcode simulator!
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
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if(emailAddressTextField.text! == "" || passwordTextField.text! == ""){
            AlertUtils.showAlert(title: "Incomplete Fields", message: "Complete all fields to login.", viewController: self)
        } else {
            
            Auth.auth().signIn(withEmail: emailAddressTextField.text! , password: passwordTextField.text!) {
                (authResult, error) in
                if (error as NSError?) != nil {
                    AlertUtils.showAlert(title: "Login Error", message: "Email may not exist or password is incorrect.", viewController: self)
                } else {
                    self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                }
            }
        }
    }
    
    
    @IBAction func faceIDLoginButtonPressed(_ sender: Any) {
        
        let context = LAContext()
        
        var error: NSError?
        
        if(context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)){
            
            //print("faceID allowed")
            let reason = "Log in to app"
        
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, 
                                   localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    
                    if success {
                        //login with appropriate email and password, then segue into home page
                        //retrieve keychain
                        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                                    kSecAttrServer as String: "www.tipple.com",
                                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                                    kSecReturnAttributes as String: true,
                                                    kSecReturnData as String: true]
                        
                        var item: CFTypeRef?
                        let status = SecItemCopyMatching(query as CFDictionary, &item)
                        
                        //there's an error, don't allow login and exit
                        if status == errSecItemNotFound {
                            
                            AlertUtils.showAlert(title: "Login Error", message: "Login credentials do not exist in the Keychain. Please login manually", viewController: self!)
                            return
                        }
                        
                        //extract login info and pass into
                        guard let keychainLogin = item as? [String: Any],
                              let passwordData = keychainLogin[kSecValueData as String] as? Data,
                              let password = String(data: passwordData, encoding: String.Encoding.utf8),
                              let email = keychainLogin[kSecAttrAccount as String] as? String
                                
                        else {
                            AlertUtils.showAlert(title: "Login Error", message: "Error getting login credentials. Please login manually", viewController: self!)
                            return
                        }
                        
                        print("email from keychain: \(email)")
                        print("password from keychain: \(password)")
                        
                        //login with keychain login info
                        Auth.auth().signIn(withEmail: email , password: password) {
                            (authResult, error) in
                            if (error as NSError?) != nil {
                                AlertUtils.showAlert(title: "Login Error", message: "Email may not exist or password is incorrect.", viewController: self!)
                            } else {
                                self?.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                            }
                        }
                        
                    } else {
                        
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginToHomeSegue", let nextVC = segue.destination as? HomeViewController {
            
            //only send values isOnKeychain returns true
            nextVC.saveOnKeychain = false
            nextVC.saveEmail = ""
            nextVC.savePassword = ""
        }
        
    }
    
}
