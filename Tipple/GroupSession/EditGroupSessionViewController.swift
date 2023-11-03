//
//  EditGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class EditGroupSessionViewController: UIViewController {

    @IBOutlet weak var editSessionNameTextField: UITextField!
    @IBOutlet weak var editSessionTimeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateSessionButtonPressed(_ sender: Any) {
        
        //TODO: get data from firebase, update it, then return new data to firebase
        
    }
    
    @IBAction func deleteSessionButtonPressed(_ sender: Any) {
        //TODO: delete session from firebase and segue back to main screen
        
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
