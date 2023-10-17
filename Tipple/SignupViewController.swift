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
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    var genderPicker = UIPickerView()
    var weightPicker = UIPickerView()
    var heightPicker = UIPickerView()
    
    let genderIdentityChoices = ["Man", "Woman", "Non-Binary"]
    let weightRangeChoices: [Int] = Array(60 ... 300)
    let heightFeetChoices: [Int] = Array(3 ... 7)
    let heightInchChoices: [Int] = Array(0 ... 11)
    
    let firestoreManager = FirestoreManager.shared
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var gender: String = ""
    var heightFeet: Int = -1
    var heightInch: Int = -1
    var weight: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: Fix error "Cannot show Automatic Strong Passwords for app bundleID: CS371L.Tipple due to error: iCloud Keychain is disabled"
        //passwordTextField.isSecureTextEntry = true
        //confirmPasswordTextField.isSecureTextEntry = true
        
        //birthdayTextField.inputView = datePicker
        genderTextField.inputView = genderPicker
        heightTextField.inputView = heightPicker
        weightTextField.inputView = weightPicker
        
        //setting picker text fields
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        heightPicker.delegate = self
        heightPicker.dataSource = self
        
        weightPicker.delegate = self
        weightPicker.dataSource = self
        
        //settings tags for pickers
        genderPicker.tag = 1
        heightPicker.tag = 2
        weightPicker.tag = 3
    }

    @IBAction func signupButtonPressed(_ sender: Any) {
        
        if(passwordTextField.text! != confirmPasswordTextField.text!){
            AlertUtils.showAlert(title: "Mismatch passwords", message: "Passwords are not the same.", viewController: self)
        } else {
            
            //only try and add user if all information is complete
            loadPersonalData()
            
            //check if all data is filled
            if(allDataFilled()) {
                
                //register user to firebase
                Auth.auth().createUser(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) {
                    (authResult, error) in
                    if let error = error as NSError? {
                        AlertUtils.showAlert(title: "Invalid Email", message: "Email address already used. Please use another.", viewController: self)
                    }
                    
                    //log in new user immediately and save data to firebase
                    if error == nil {
                        Auth.auth().signIn(withEmail: self.emailAddressTextField.text!, password: self.passwordTextField.text!)
                        self.performSegue(withIdentifier: "signupToHomeSegue", sender: nil)
                        
                        //add information to fire base
                        if let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email {
                            self.firestoreManager.createUserDocument(
                                                            userID: userId,
                                                            firstName: self.firstName,
                                                            lastName: self.lastName,
                                                            phoneNumber: self.phoneNumber,
                                                            birthday: self.birthdayPicker.date,
                                                            gender: self.gender,
                                                            heightFeet: self.heightFeet,
                                                            heightInches: self.heightInch,
                                                            weight: self.weight,
                                                            email: email)
                        } else {
                            AlertUtils.showAlert(title: "Error Registering Data", message: "Try again later.", viewController: self)
                        }
                    }
                }
            } else {
                AlertUtils.showAlert(title: "Missing Information", message: "Complete all fields to register new account.", viewController: self)
            }
        }
    }
    
    
    @IBAction func loginTextButtonPressed(_ sender: Any) {
            performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    func loadPersonalData() {
        firstName = firstNameTextField.text!
        lastName = lastNameTextField.text!
        phoneNumber = phoneNumberTextField.text!
    }
    
    //checks if all text fields were filled
    func allDataFilled() -> Bool{
        if(passwordTextField.text! != "" &&
           confirmPasswordTextField.text! != "" &&
           firstName != "" &&
           lastName != "" &&
           phoneNumber != "" &&
           gender != "" &&
           heightFeet != -1 &&
           heightInch != -1 &&
           weight != -1){
            return true
        }
        return false
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
            
            if(component == 0) {
                return heightFeetChoices.count
            } else {
                return heightInchChoices.count
            }
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
            
            if(component == 0) {
                return String(heightFeetChoices[row])
            } else {
                return String(heightInchChoices[row])
            }
        case 3:
            return String(weightRangeChoices[row])
        default:
            return "No data available"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            gender = genderIdentityChoices[row]
            
            genderTextField.text = gender
            genderTextField.resignFirstResponder()
        case 2:
            heightFeet = heightFeetChoices[pickerView.selectedRow(inComponent: 0)]
            heightInch = heightInchChoices[pickerView.selectedRow(inComponent: 1)]
            
            heightTextField.text = "\(heightFeet)\' \(heightInch)\" "
            heightTextField.resignFirstResponder()
        case 3:
            weight = weightRangeChoices[row]
            
            weightTextField.text = String(weight)
            weightTextField.resignFirstResponder()
        default:
            return
        }
    }
}
