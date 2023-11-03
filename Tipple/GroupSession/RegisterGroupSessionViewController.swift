//
//  RegisterGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class RegisterGroupSessionViewController: UIViewController {

    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var endSessionTextField: UITextField!

    var currentSession: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //TODO: add custom picker view data content

    @IBAction func createSessionButtonPressed(_ sender: Any) {
        
        //TODO: take in values from text field and save to firebase in session struct, discuss with Andrew on how to format group session with QuestionnaireVC
        
        //update current session list and group end time
        self.currentSession?.sessionName = sessionNameTextField.text
        
        
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
