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
    
    var currentSession: SessionInfo?
    var groupQRCode: UIImage?
    var manageGroupSegue = "manageGroupSessionSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //TODO: take out after testing
        currentSession = SessionInfo()
    }
    
    @IBAction func createSessionButtonPressed(_ sender: Any) {
        
        //TODO: take in values from text field and save to firebase in session struct, discuss with Andrew on how to format group session with QuestionnaireVC
        
        if(sessionNameTextField.text != ""){
            //update current session list and group end time
            self.currentSession?.sessionName = sessionNameTextField.text
            self.currentSession?.endGroupSessionTime = endSessionDateTimePicker.date
            
            //generate and save group session's QR code using the initial session name string + date and time string
            groupQRCode = generateQRCode(from: "\(sessionNameTextField.text ?? "default string") \(DateFormatter().string(from: endSessionDateTimePicker.date))")
        
            //segue to new screen
            performSegue(withIdentifier: manageGroupSegue, sender: self)
        }
    }
    
    //boiler plate code
    //TODO: generate a QR code here using the initial session name string + date and time string, connect QR code to add individual to group session (Andrew part)
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
        
        finalDestination.currentSession = self.currentSession
        finalDestination.groupQRCode = self.groupQRCode
    }

}
