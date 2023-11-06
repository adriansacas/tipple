//
//  ManageGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit
import Foundation

//protocol to update session name
protocol EditSession {
    func changeSessionName(newSessionName:String)
    func changeEndSessionDateTime(newEndDateTime:Date)
}

class ManageGroupSessionVC: UIViewController, EditSession {
    
    @IBOutlet weak var sessionNameTextLabel: UILabel!
    @IBOutlet weak var sessionEndDateTimeLabel: UILabel!
    let firestoreManager = FirestoreManager.shared

    var currentSession: SessionInfo?
    var groupQRCode: UIImage?
    var sessionID: String?
    var userID: String?
    
    
    var inviteCodeSegue = "inviteCodeSegue"
    var sessionSettingSegue = "sessionSettingSegue"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        firestoreManager.getSessionInfo(userID: self.userID!, sessionDocumentID: self.sessionID!) { sessionTemp, error in
            if let error = error {
                print("Error retrieving session: \(error)")
            } else if let sessionTemp = sessionTemp {
                self.currentSession = sessionTemp
                
                // Display current session name and end date/time
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .short
                let formattedDate = dateFormatter.string(from: self.currentSession!.endGroupSessionTime!)
                
                self.sessionNameTextLabel.text = self.currentSession?.sessionName
                self.sessionEndDateTimeLabel.text = formattedDate
                
                print("Session successfully retrieved before view appearing with document ID: \(self.sessionID ?? "Value not set")")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func changeSessionName(newSessionName: String) {
        currentSession?.sessionName = newSessionName
        sessionNameTextLabel.text = newSessionName
    }
    
    func changeEndSessionDateTime(newEndDateTime: Date) {
        currentSession?.endGroupSessionTime = newEndDateTime
        
        // Update end session date and time label
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: currentSession!.endGroupSessionTime!)
        sessionEndDateTimeLabel.text = formattedDate
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == inviteCodeSegue, let destination = segue.destination as? InviteCodeVC {
            
            destination.currentSession = self.currentSession
            destination.groupQRCode = self.groupQRCode
            
        } else if segue.identifier == sessionSettingSegue, let destination = segue.destination as? EditGroupSessionVC {
            
            destination.delegate = self
            destination.currentSession = self.currentSession
            
        }
    }

}
