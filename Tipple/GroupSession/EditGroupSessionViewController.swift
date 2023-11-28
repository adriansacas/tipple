//
//  EditGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class EditGroupSessionVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var editSessionNameTextField: UITextField!
    @IBOutlet weak var editEndSessionDateTimePicker: UIDatePicker!
    
    var delegate:UIViewController?
    var deleteToHomeSegue = "editSessionToHomeSegue"
    var sessionName: String = ""
    var endDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editSessionNameTextField.delegate = self
        
        //Update text field to current session and time
        editSessionNameTextField.text = sessionName
        editEndSessionDateTimePicker.date = endDate
        
        editEndSessionDateTimePicker.datePickerMode = .dateAndTime
    }
    
    @IBAction func updateSessionButtonPressed(_ sender: Any) {
        
        //display warning to fill all fields
        if(editSessionNameTextField.text == ""){
            AlertUtils.showAlert(title: "Missing Information", message: "Complete all fields to register new account.", viewController: self)
            return
        }
        
        //display warning if too much chars
        if(editSessionNameTextField.text!.count > 15){
            AlertUtils.showAlert(title: "Max Characters Reached", message: "Session name can only contain at most 15 characters including spaces.", viewController: self)
            return
        }
        
        //check if new time is before current time
        let currentDateTime = Date()
        if(editEndSessionDateTimePicker.date < currentDateTime){
            AlertUtils.showAlert(title: "Invalid Time Set", message: "End time must be after the current time.", viewController: self)
            return
        }
        
        //call protocol functions to update session
        let mainVC = delegate as? EditSession
        let newSessionFields = ["sessionName" : (editSessionNameTextField.text ?? "") as String,
                                "endTime" : editEndSessionDateTimePicker.date] as [String : Any]
        mainVC?.updateSessionInfo(sessionFields: newSessionFields)
    }
    
    @IBAction func deleteSessionButtonPressed(_ sender: Any) {
        
        let deleteAlertController = UIAlertController(
            title: "Are you sure you want to delete?",
            message: "The current session will not be saved.",
            preferredStyle: .alert
        )
        
        deleteAlertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .default)
        )
        
        deleteAlertController.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: {
                (action) in
                
                //TODO: assumes the user stayed logged in, find better solution
                self.performSegue(withIdentifier: self.deleteToHomeSegue, sender: nil)
            })
        )
        
        present(deleteAlertController, animated: true)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == deleteToHomeSegue,  let destination = segue.destination as? HomeViewController {
            // handle firebase marking of end session
            //call protocol functions to update session
            let mainVC = delegate as? EditSession
            mainVC?.endSessionForUser()
            
            destination.saveOnKeychain = false
            destination.saveEmail = ""
            destination.savePassword = ""
        }
    }
}
