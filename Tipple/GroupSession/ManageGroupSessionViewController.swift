//
//  ManageGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit
import Foundation

class ManageGroupSessionVC: UIViewController {

    @IBOutlet weak var sessionNameTextLabel: UILabel!
    @IBOutlet weak var sessionEndDateTimeLabel: UILabel!
    
    var currentSession: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display current session name and end date/time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: currentSession!.endGroupSessionTime)
        
        sessionNameTextLabel.text = currentSession?.sessionName
        sessionEndDateTimeLabel.text = formattedDate
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
