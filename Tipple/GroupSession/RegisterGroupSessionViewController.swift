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
    var manageGroupSegue = "manageGroupSessionSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //TODO: take out after testing
        currentSession = SessionInfo()
    }
    
    //TODO: add custom picker view data content

    @IBAction func createSessionButtonPressed(_ sender: Any) {
        
        //TODO: take in values from text field and save to firebase in session struct, discuss with Andrew on how to format group session with QuestionnaireVC
        
        if(sessionNameTextField.text != ""){
            //update current session list and group end time
            self.currentSession?.sessionName = sessionNameTextField.text
            self.currentSession?.endGroupSessionTime = endSessionDateTimePicker.date
            //print(endSessionDateTimePicker.date)
        
            //segue to new screen
            performSegue(withIdentifier: manageGroupSegue, sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? UINavigationController else {
                return
        }
        
        guard let finalDestination = destination.viewControllers.first as? ManageGroupSessionVC else {
                return
            }
        
        finalDestination.currentSession = self.currentSession
    }

}
