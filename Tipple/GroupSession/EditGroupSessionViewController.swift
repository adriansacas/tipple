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
        editEndSessionDateTimePicker.date = currentSession!.endGroupSessionTime
    }
    
    @IBAction func updateSessionButtonPressed(_ sender: Any) {
        
        //check if text field is filled
        if(editSessionNameTextField.text != "") {
            //call protocol functions
            let mainVC = delegate as? EditSession
            mainVC?.changeSessionName(newSessionName: editSessionNameTextField.text!)
            mainVC?.changeEndSessionDateTime(newEndDateTime: editEndSessionDateTimePicker.date)
        }
    }
    
    @IBAction func deleteSessionButtonPressed(_ sender: Any) {
        
        //TODO: have alerts to ensure decision, then don't save session and segue back to main screen
        
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
