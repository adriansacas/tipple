//
//  QuestionnaireVC.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import UIKit
import FirebaseAuth

class QuestionnaireVC: UIViewController {
    

    @IBOutlet weak var eatenToggle: UISwitch!
    @IBOutlet weak var shareSession: UISwitch!
    @IBOutlet weak var partyLocation: UISearchBar!
    @IBOutlet weak var endLocation: UISearchBar!
    @IBOutlet weak var startButton: UIButton!
    
    var sessionType: String?
    var userID: String?
    var sessionID: String?
    var userProfileInfo: ProfileInfo?    
    let firestoreManager = FirestoreManager.shared
    let qToActiveSegue = "questionToActiveSegue"
    let qToGroupSegue  = "questionToGroupManage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(sessionType ?? "No Session Type Passed")

        
        if self.sessionType == "Group" {
            startButton.setTitle("Continue", for: .normal)
        } else if self.sessionType == "Join" {
            startButton.setTitle("Join Session", for: .normal)
        }
        
        
        // Do any additional setup after loading the view.
        getUserID()
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Just ensuring that the search fields are getting reset at the end of a view
        partyLocation.text = nil
        endLocation.text = nil
    }
    
    
    func getUserProfileData(user: String) {
        firestoreManager.getUserData(userID: user) { [weak self] (profileInfo, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let profileInfo = profileInfo {
                self?.userProfileInfo = profileInfo
            }
        }
        
    }
    
    func getUserID() {
        if let userID = Auth.auth().currentUser?.uid {
            self.userID = userID
            getUserProfileData(user: userID)
        } else {
            print("Error fetching user ID from currentUser")
        }
    }
    
    @IBAction func startSessionButton(_ sender: Any) {
        guard (self.sessionType != nil) else {
            return
        }
        
        if self.sessionType == "Individual" || self.sessionType == "Group" {
            let session = SessionInfo(createdBy: self.userID!,
                                      membersList: [self.userID!],
                                      sessionType: self.sessionType!,
                                      startTime: Date.now,
                                      drinksInSession: [],
                                      stillActive: true,
                                      startLocation: partyLocation.text ?? "",
                                      endLocation: endLocation.text ?? "",
                                      ateBefore: eatenToggle.isOn,
                                      sessionName: "My Session",
                                      shareSession: shareSession.isOn)
            
            
            
            firestoreManager.addSessionInfo(userID: self.userID!, session: session) { documentID, error in
                if let error = error {
                    print("Error adding session: \(error)")
                } else if let documentID = documentID {
                    self.sessionID = documentID
                    print("Session added successfully with document ID: \(self.sessionID ?? "Value not set")")
                    
                    
                    if self.sessionType == "Individual" {
                        self.performSegue(withIdentifier: self.qToActiveSegue, sender: self)
                    } else {
                        self.performSegue(withIdentifier: self.qToGroupSegue, sender: self)
                    }
                    
                }
            }
        }
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == qToActiveSegue,
           let destination = segue.destination as? ShowActiveVC {
            destination.userID = self.userID
            destination.userProfileInfo = self.userProfileInfo
            destination.sessionID = self.sessionID
        }
        
        if segue.identifier == qToGroupSegue,
           let destination = segue.destination as? RegisterGroupSessionVC {
            destination.userID = self.userID
            destination.sessionID = self.sessionID
        }
    }
    
}
