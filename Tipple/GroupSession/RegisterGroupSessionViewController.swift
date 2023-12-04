//
//  RegisterGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class RegisterGroupSessionVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var endSessionDateTimePicker: UIDatePicker!
    
    let firestoreManager = FirestoreManager.shared
    var sessionID: String?
    var userID: String?
    var manageGroupSegue = "manageGroupSessionSegue"
    var isDD: Bool?
    var isLocationEnabled: Bool?
    var sessionObj: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionNameTextField.delegate = self
        
        // Do any additional setup after loading the view.
        endSessionDateTimePicker.datePickerMode = .dateAndTime
    }
    

    
    @IBAction func createSessionButtonPressed(_ sender: Any) {
        
        //display warning to fill all fields
        if(sessionNameTextField.text == ""){
            AlertUtils.showAlert(title: "Missing Information", message: "Complete all fields to register new account.", viewController: self)
            return
        }
        
        //display warning if too much chars
        if(sessionNameTextField.text!.count > 15){
            AlertUtils.showAlert(title: "Max Characters Reached", message: "Session name can only contain at most 15 characters including spaces.", viewController: self)
            return
        }
        
        //check if new time is before current time
        let currentDateTime = Date()
        if(endSessionDateTimePicker.date < currentDateTime){
            AlertUtils.showAlert(title: "Invalid Time Set", message: "End time must be after the current time.", viewController: self)
            return
        }
        
        //update current session list and group end time
        let newSessionFields = ["sessionName" : (sessionNameTextField.text ?? "") as String,
                                "endTime" : endSessionDateTimePicker.date] as [String : Any]
        
        firestoreManager.addSessionInfo(userID: self.userID!, session: self.sessionObj!) { documentID, error in
            if let error = error {
                print("Error adding session: \(error)")
            } else if let documentID = documentID {
                self.sessionID = documentID
                print("Session added successfully with document ID: \(self.sessionID ?? "Value not set")")
                self.firestoreManager.updateGroupSession(userID: self.userID!, sessionID: self.sessionID!, fields: newSessionFields) { [self] error in
                    if let error = error {
                        print("Error adding session: \(error)")
                    } else {
                        //segue to new screen
                        self.performSegue(withIdentifier: self.manageGroupSegue, sender: self)
                    }
                }
            }
        }
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
        
        guard let destination = segue.destination as? UINavigationController else {
            return
        }
        
        guard let finalDestination = destination.viewControllers.first as? ManageGroupSessionVC else {
            return
        }
        
        finalDestination.userID = self.userID
        finalDestination.sessionID = self.sessionID
        finalDestination.sessionName = self.sessionNameTextField.text!
        finalDestination.endDate = endSessionDateTimePicker.date
        finalDestination.isDD = self.isDD
        finalDestination.isLocationEnabled = self.isLocationEnabled!
    }

}
