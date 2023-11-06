//
//  RegisterGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class RegisterGroupSessionVC: UIViewController {

    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var endSessionDateTimePicker: UIDatePicker!
    
    let firestoreManager = FirestoreManager.shared
    var sessionID: String?
    var userID: String?
    var generatedQR: UIImage?
    var manageGroupSegue = "manageGroupSessionSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func createSessionButtonPressed(_ sender: Any) {
        
        //TODO: take in values from text field and save to firebase in session struct, discuss with Andrew on how to format group session with QuestionnaireVC
        
        if(sessionNameTextField.text != ""){
            //update current session list and group end time
            
            let newSessionFields = ["sessionName" : (sessionNameTextField.text ?? "") as String,
                                    "endTime" : endSessionDateTimePicker.date] as [String : Any]
            
            firestoreManager.updateGroupSession(userID: self.userID!, sessionID: self.sessionID!, fields: newSessionFields) { error in
                if let error = error {
                    print("Error adding session: \(error)")
                } else {
                    print("Successfully added updated the session group")
                    //generate and save group session's QR code using the sessionID
                    self.generatedQR = self.generateQRCode(from: self.sessionID!)
                
                    //segue to new screen
                    self.performSegue(withIdentifier: self.manageGroupSegue, sender: self)
                }
            }
            

        }
    }
    
    //boiler plate code
    //TODO: generate a QR code here using the sessionID string, connect QR code to add individual to group session (Andrew part)
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
    }

}
