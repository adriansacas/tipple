//
//  ShowActiveVC.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import UIKit

class ShowActiveVC: UIViewController {
    
    var userID: String?
    var sessionID: String?
    var userProfileInfo: ProfileInfo?
    var currentSession: SessionInfo?
    let firestoreManager = FirestoreManager.shared
    var drinkIncreaseAlert: UIAlertController?
    
    var incrementDrinkBy: Int = 0
    var runningBAC: Float = 0.0
    var runningStatus: String = "😄"
    var runningDrinkCounter: Int = 0
    let endSessionSegue = "exitToMain"
    
    let indicies = ["BAC": 0,
                    "STATUS": 1,
                    "NUMDRINK": 2]
    
    @IBOutlet weak var drinkSelectorSegmented: UISegmentedControl!
    @IBOutlet weak var statusSegmented: UISegmentedControl!
    @IBOutlet weak var navItemTitle: UINavigationItem!
    @IBOutlet weak var mainGlassIV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up an action for the drink selector
        drinkSelectorSegmented.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Ensure that the status segmented controller is always disabled for users (for now)
        statusSegmented.isUserInteractionEnabled = false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        firestoreManager.getSessionInfo(userID: self.userID!, sessionDocumentID: self.sessionID!) { sessionTemp, error in
            if let error = error {
                print("Error adding session: \(error)")
            } else if let sessionTemp = sessionTemp {
                self.currentSession = sessionTemp
                self.navItemTitle.title = self.currentSession?.sessionName ?? ""
                
                if self.userProfileInfo == nil {
                    self.firestoreManager.getUserData(userID: self.userID!) { [weak self] (profileInfo, error) in
                        if let error = error {
                            print("Error fetching user data: \(error.localizedDescription)")
                        } else if let profileInfo = profileInfo {
                            self?.userProfileInfo = profileInfo
                            self?.setStatusInfo()
                        }
                    }
                }
                
                print("Session successfully retrieved before view appearing with document ID: \(self.sessionID ?? "Value not set")")
            }
        }
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        drinkIncreaseAlert = UIAlertController(
                                title: "How Many Drinks?",
                                message: "Please choose a value:",
                                preferredStyle: UIAlertController.Style.alert)



        drinkIncreaseAlert?.addAction(UIAlertAction(title: "cancel", style: .default, handler: { (action: UIAlertAction!) in
            self.incrementDrinkBy = 0
            sender.selectedSegmentIndex = -1
        }))
        
        drinkIncreaseAlert?.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

            // Create all the drinks and add them to the session
            if let drinkType = sender.titleForSegment(at: sender.selectedSegmentIndex){
                if self.incrementDrinkBy > 0{
                    self.updateDrinks(drinkType: drinkType, amount: self.incrementDrinkBy)
                    self.incrementDrinkBy = 0
                    // Update fields in the status bar
                    self.updateStatusInfo(bacValue: self.runningBAC, status: self.runningStatus, drinks: self.runningDrinkCounter)
                }
            }
            

            
            sender.selectedSegmentIndex = -1
        }))

        // Add a stepper to the alert controller
        drinkIncreaseAlert?.addTextField { textField in
            textField.placeholder = "Enter a value"
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.incrementDrinkByChanged), for: .editingChanged)
        }

        self.present(drinkIncreaseAlert!, animated: true, completion: nil)
    }
    
    
    // Function to store the amount inputed by user in the text field
    @objc func incrementDrinkByChanged(_ textField: UITextField) {
        if let text = textField.text, let value = Int(text) {
            incrementDrinkBy = value
        }
    }
    
    
    // Function to update the segmented control status field at top of view
    func updateStatusInfo(bacValue: Float, status: String, drinks: Int) {
        statusSegmented.setTitle(String(format: "%.2f", bacValue), forSegmentAt: indicies["BAC"]!)
        statusSegmented.setTitle(status, forSegmentAt: indicies["STATUS"]!)
        statusSegmented.setTitle(String(drinks), forSegmentAt: indicies["NUMDRINK"]!)
        
        if bacValue < 0.08 {
            mainGlassIV.image = UIImage(named: "Tipple_Green_Status")
        } else if (bacValue < 0.12) {
            mainGlassIV.image = UIImage(named: "Tipple_Yellow_Status")
        } else {
            mainGlassIV.image = UIImage(named: "Tipple_Red_Status")
        }
    }
    
    
    func setStatusInfo(){
        let drinks: [DrinkInfo] = self.currentSession!.drinksInSession
        var tempBAC: Float = 0
        if !drinks.isEmpty{
            let latestDrink = drinks.max(by: { $0.timeAt < $1.timeAt })
            tempBAC = latestDrink!.bacAtTime
        }
        
        self.runningDrinkCounter = drinks.count
        self.runningBAC = tempBAC
        self.runningStatus = calculateStatus()
        
        updateStatusInfo(bacValue: self.runningBAC,
                         status: self.runningStatus,
                         drinks: self.runningDrinkCounter)
    }
    
    func updateDrinks(drinkType: String, amount: Int) {
        print("Drink: \(drinkType) x \(amount)")
        print("Creating the drinkObjects to add to a given session")
        
        let prevDrinkAmount = self.runningDrinkCounter
        self.runningDrinkCounter += amount      // Increment the running amount of drinks
        self.runningBAC = calculateBac()      // Calculate the new BAC
        self.runningStatus = calculateStatus()  // Calculate the new status based on BAC
        
        var drinkObjects: [DrinkInfo] = []
        
        for drinkNum in 1...amount {
            let tempDrink = DrinkInfo(drinkType: drinkType,
                                      drinkNumIn: prevDrinkAmount + drinkNum,
                                      bacAtTime: self.runningBAC)
            
            drinkObjects.append(tempDrink)
        }
        
        // Update the session object with new drinks
        self.currentSession?.drinksInSession.append(contentsOf: drinkObjects)

        guard self.sessionID != nil else {
            print("NO SESSION ID STORED -- NOT UPDATING FIREBASE")
            return
        }
        
        
        // Update Firestore with the new drinks
        firestoreManager.updateDrinksInSession(userID: self.userID!,
                                               sessionID: self.sessionID!,
                                               drinksToAdd: drinkObjects) { error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                print("Session updated with : \(self.sessionID ?? "")")
            }
        }
        
    }
    
    
    func calculateBac() -> Float {
         guard self.userProfileInfo != nil else {
             print("Do Not Have User Profile Information")
             return 0.0
         }
         
         let r: Float = self.userProfileInfo!.gender == "Male" ? 0.68 : 0.55
         let alcConsumedInGrams = Float(self.runningDrinkCounter * 14)
         let bodyWeight = Float(self.userProfileInfo!.weight) * 0.45359237

         let bac = (alcConsumedInGrams / (bodyWeight * 1000.0 * r)) * 100.0

         return bac
    }
    
    func calculateStatus() -> String {
        if self.runningBAC < 0.08 {
            return "😀"
        } else if (self.runningBAC < 0.12) {
            AlertUtils.showAlert(title: "Slow down!", message: "You've had a few drinks, take a break and drink some water", viewController: self)
            return "🤢"
        } else {
            AlertUtils.showAlert(title: "Tap out", message: "Time to stop drinking, make sure to hydrate!", viewController: self)
            return "💀"
        }
    }

    @IBAction func exitSession(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Finish Session",
            message: "Are you sure you want to finish your session?",
            preferredStyle: .alert
        )

        // Add a "Cancel" action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Add a "Finish" action
        // TODO: Mark a session as finished one they exit to the main page.
        alertController.addAction(UIAlertAction(title: "Finish", style: .destructive) { _ in
            self.performSegue(withIdentifier: self.endSessionSegue, sender: self)
        })

        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.endSessionSegue {
            // handle firebase marking of end session
            firestoreManager.endSessionForUser(userID: self.userID!,
                                               sessionID: self.sessionID!) { error in
                if let error = error {
                    print("Error ending session: \(error)")
                }
            }
        }
    }
}
