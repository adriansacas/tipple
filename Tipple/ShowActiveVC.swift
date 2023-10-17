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
    
    let indicies = ["BAC": 0,
                    "STATUS": 1,
                    "NUMDRINK": 2]

    @IBOutlet weak var drinkSelectorSegmented: UISegmentedControl!
    @IBOutlet weak var statusSegmented: UISegmentedControl!
    @IBOutlet weak var navItemTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firestoreManager.addSessionInfo(userID: self.userID!, session: self.currentSession!) { documentID, error in
            if let error = error {
                print("Error adding session: \(error)")
            } else if let documentID = documentID {
                self.sessionID = documentID
                print("Session added successfully with document ID: \(self.sessionID ?? "Value not set")")
            }
        }
        
        
        // Set up an action for the drink selector
        drinkSelectorSegmented.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Ensure that the status segmented controller is always disabled for users (for now)
        statusSegmented.isUserInteractionEnabled = false
        updateStatusInfo(bacValue: runningBAC, status: runningStatus, drinks: runningDrinkCounter)
        
        // Setup the navbar title and other items
        if currentSession != nil {
            navItemTitle.title = currentSession?.sessionName
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
                self.updateDrinks(drinkType: drinkType, amount: self.incrementDrinkBy)
                self.incrementDrinkBy = 0
                // Update fields in the status bar
                self.updateStatusInfo(bacValue: self.runningBAC, status: self.runningStatus, drinks: self.runningDrinkCounter)
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
            return "🤢"
        } else {
            return "💀"
        }
    }



}
