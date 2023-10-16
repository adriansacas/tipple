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
    
    var userID: String?
    var userProfileInfo: ProfileInfo?
    var currentSession: SessionInfo?
    let firestoreManager = FirestoreManager.shared
    let qToActiveSegue = "questionToActiveSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserID()
        getUserProfileData()
    }
    
    
    func getUserProfileData() {
        firestoreManager.getUserData(userID: self.userID!) { [weak self] (profileInfo, error) in
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
        } else {
            print("Error fetching user ID from currentUser")
        }
    }
    
    @IBAction func startSessionButton(_ sender: Any) {
        let session = SessionInfo(
            startTime: Date.now,
            sessionType: "Individual",
            drinksInSession: [],
            startLocation: partyLocation.text ?? "",
            endLocation: endLocation.text ?? "",
            ateBefore: eatenToggle.isOn,
            sessionName: "My Session",
            shareSession: shareSession.isOn,
            membersList: []
        )
        
        guard let userID = self.userID else {
            print("No User ID Available")
            return
        }
        
        firestoreManager.addSessionInfo(userID: userID, session: session) {
            error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                print("Session added successfully")
            }
        }
        
        self.currentSession = session
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == qToActiveSegue,
           let destination = segue.destination as? ShowActiveVC {
            destination.userID = self.userID
            destination.userProfileInfo = self.userProfileInfo
            destination.currentSession = self.currentSession
        }
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
