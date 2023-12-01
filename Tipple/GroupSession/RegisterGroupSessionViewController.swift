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
    var generatedQR: UIImage?
    var manageGroupSegue = "manageGroupSessionSegue"
    var isDD: Bool?
    
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
        
        firestoreManager.updateGroupSession(userID: self.userID!, sessionID: self.sessionID!, fields: newSessionFields) { error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                //generate and save group session's QR code using the sessionID
                self.generatedQR = self.generateQRCode(from: self.sessionID!)
            
                //segue to new screen
                self.performSegue(withIdentifier: self.manageGroupSegue, sender: self)
            }
        }

    }
    
    //boiler plate code
    //TODO: move code genration to ManageViewControllerView!
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
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
        
        finalDestination.groupQRCode = self.generatedQR
        finalDestination.userID = self.userID
        finalDestination.sessionID = self.sessionID
        finalDestination.sessionName = self.sessionNameTextField.text!
        finalDestination.endDate = endSessionDateTimePicker.date
        finalDestination.isDD = self.isDD
    }

}
