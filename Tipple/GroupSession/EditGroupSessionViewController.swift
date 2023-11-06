//
//  EditGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class EditGroupSessionVC: UIViewController {

    @IBOutlet weak var editSessionNameTextField: UITextField!
    @IBOutlet weak var editEndSessionDateTimePicker: UIDatePicker!
    
    var delegate:UIViewController?
    var currentSession: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Update text field to current session and time
        editSessionNameTextField.text = currentSession?.sessionName
        editEndSessionDateTimePicker.date = currentSession!.endGroupSessionTime!
    }
    
    @IBAction func updateSessionButtonPressed(_ sender: Any) {
        
        //check if text field is filled
        if(editSessionNameTextField.text != "") {
            //call protocol functions
            let mainVC = delegate as? EditSession
            let newSessionFields = ["sessionName" : (editSessionNameTextField.text ?? "") as String,
                                    "endTime" : editEndSessionDateTimePicker.date] as [String : Any]
            
            mainVC?.updateSessionInfo(sessionFields: newSessionFields)
        }
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
                self.performSegue(withIdentifier: "editSessionToHomeSegue", sender: nil)
            })
        )
        
        present(deleteAlertController, animated: true)
    }

}
