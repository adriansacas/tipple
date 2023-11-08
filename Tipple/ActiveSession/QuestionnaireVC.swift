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
    var sessionName: String?
    var endDate: Date?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    let qToActiveSegue = "questionToActiveSegue"
    let qToGroupSegue  = "questionToGroupManage"
    let qToGroupJoinSegue = "questionsToGroupJoin"
    
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
        
        let dispatchGroup = DispatchGroup()

        
        if self.sessionType == "Individual" || self.sessionType == "Group" {
            dispatchGroup.enter()
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
                    dispatchGroup.leave()
                }
            }
        } else if self.sessionType == "Join" {
            dispatchGroup.enter()
            /* HARDCODED SESSION TO JOIN ATM
                TODO: MAKE SURE THE SESSION YOU"RE JOINING IS A GROUP SESSION
             */
            self.sessionID = "gcCUtlRxKclzwhlYK8dW"
            let session = SessionInfo()
            session.startTime = Date.now
            session.drinksInSession = []
            session.stillActive = true
            session.startLocation = partyLocation.text ?? ""
            session.endLocation = endLocation.text ?? ""
            session.ateBefore = eatenToggle.isOn
            session.shareSession = shareSession.isOn
            
            
            self.firestoreManager.getSessionInfo(userID: self.userID!, sessionDocumentID: self.sessionID!) { sessionTemp, error in
                if let error = error {
                    print("Error adding session: \(error)")
                } else if let sessionTemp = sessionTemp {
                    if sessionTemp.membersList.contains(self.userID!){
                        let stopAlertController = UIAlertController(
                                                            title: "Cannot Rejoin Session",
                                                            message: "Cannot Rejoin Session After Leaving",
                                                            preferredStyle: .alert
                        )
                        
                        stopAlertController.addAction(UIAlertAction(
                                                title: "OK",
                                                style: .destructive,
                                                handler: {
                                                    (action) in
                                                    dispatchGroup.suspend()
                                                    self.dismiss(animated: true)
                                                })
                        )
                        
                        self.present(stopAlertController, animated: true)
                    } else {
                        self.sessionName = sessionTemp.sessionName
                        self.endDate = sessionTemp.endGroupSessionTime
                        self.firestoreManager.addMembersToSession(sessionID: self.sessionID!,
                                                             userID: self.userID!,
                                                             session: session) { error in
                            if let error = error {
                                print("Error adding member to session: \(error)")
                            } else {
                                dispatchGroup.leave()
                            }

                        }
                    }
                }
            }
            

        }
        
        dispatchGroup.notify(queue: .main) {
            if self.sessionType == "Individual" {
                self.performSegue(withIdentifier: self.qToActiveSegue, sender: self)
            } else if self.sessionType == "Group"{
                self.performSegue(withIdentifier: self.qToGroupSegue, sender: self)
            } else if self.sessionType == "Join" {
                print("Session successfully retrieved for joining with document ID: \(self.sessionID ?? "Value not set") \nUserID: \(self.userID ?? "No User")\nSessionEnd:\(self.endDate?.description ?? "no end")")
                self.performSegue(withIdentifier: self.qToGroupJoinSegue, sender: nil)
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
        
        if segue.identifier == qToGroupJoinSegue{
           
            guard let destination = segue.destination as? UINavigationController else {
                return
            }
            
            guard let finalDestination = destination.viewControllers.first as? ManageGroupSessionVC? else {
                return
            }
            
            finalDestination!.sessionName = self.sessionName!
            finalDestination!.endDate = self.endDate!
            finalDestination!.userID = self.userID
            finalDestination!.sessionID = self.sessionID
            finalDestination!.isManager = false

        }
    }
    
}
