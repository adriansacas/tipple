//
//  LoginViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordTextField.isSecureTextEntry = true;
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        //TODO: Error if emailAddress and text field are empty
        if(emailAddressTextField.text! == "" || passwordTextField.text! == ""){
            self.errorStatus.text = "Please fill in all fields to login"
        } else {
            Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.errorStatus.text = "\(error.localizedDescription)"
                } else {
                    self.errorStatus.text = ""
                    self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
                }
            }
        }
    }
    
    @IBAction func signupTextButtonPressed(_ sender: Any){
        performSegue(withIdentifier: "signupSegue", sender: nil)
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
