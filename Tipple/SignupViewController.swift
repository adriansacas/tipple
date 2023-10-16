//
//  SignupViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var errorStatus: UILabel!
    
    
    var genderPicker = UIPickerView()
    var weightPicker = UIPickerView()
    
    let genderIdentityChoices = ["Man", "Woman", "Non-Binary"]
    let weightRangeChoices: [Int] = Array(60 ... 300)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: Fix error "Cannot show Automatic Strong Passwords for app bundleID: CS371L.Tipple due to error: iCloud Keychain is disabled"
        //passwordTextField.isSecureTextEntry = true
        //confirmPasswordTextField.isSecureTextEntry = true
        
        genderTextField.inputView = genderPicker
        weightTextField.inputView = weightPicker
        
        //setting picker text fields
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        weightPicker.delegate = self
        weightPicker.dataSource = self
        
        //settings tags for pickers
        genderPicker.tag = 1
        //height picker
        weightPicker.tag = 3
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
            //performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 1
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            return genderIdentityChoices.count
        case 2:
            return 0
        case 3:
            return weightRangeChoices.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return genderIdentityChoices[row]
        case 2:
            return "No height data yet"
        case 3:
            return String(weightRangeChoices[row])
        default:
            return "No data available"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            genderTextField.text = genderIdentityChoices[row]
            genderTextField.resignFirstResponder()
        case 2:
            return //TODO
        case 3:
            weightTextField.text = String(weightRangeChoices[row])
            weightTextField.resignFirstResponder()
        default:
            return
        }
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
