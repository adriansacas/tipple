//
//  ShowActiveVC.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import UIKit

class ShowActiveVC: UIViewController {
    
    var userID: String?
    var userProfileInfo: ProfileInfo?
    var currentSession: SessionInfo?
    var stepperValue: Int = 0
    var drinkIncreaseAlert: UIAlertController?
    
    let indicies = ["BAC": 0,
                    "STATUS": 1,
                    "NUMDRINK": 2]
    

    @IBOutlet weak var drinkSelectorSegmented: UISegmentedControl!
    @IBOutlet weak var statusSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(currentSession?.startTime)")

        // Set up an action for the drink selector
        drinkSelectorSegmented.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Ensure that the status segmented controller is always disabled for users (for now)
        statusSegmented.isUserInteractionEnabled = false
        statusSegmented.setTitle("0.0", forSegmentAt: indicies["BAC"]!)
        statusSegmented.setTitle(":)", forSegmentAt: indicies["STATUS"]!)
        statusSegmented.setTitle("0", forSegmentAt: indicies["NUMDRINK"]!)
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        drinkIncreaseAlert = UIAlertController(
                                title: "How Many Drinks?",
                                message: "Please choose a value:",
                                preferredStyle: UIAlertController.Style.alert)



        drinkIncreaseAlert?.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
        drinkIncreaseAlert?.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

            // Write your code here
            // Handle the OK action, if needed
            print("Selected stepper value: \(self.stepperValue)")
            let index = sender.selectedSegmentIndex
            if let drinkType = sender.titleForSegment(at: index){
                print("Drink Type Selected: \(drinkType)")
            }
            //callDrinkMakerHere
        }))

        // Add a stepper to the alert controller
        drinkIncreaseAlert?.addTextField { textField in
            textField.placeholder = "Enter a value"
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.stepperValueChanged), for: .editingChanged)
        }


        self.present(drinkIncreaseAlert!, animated: true, completion: nil)
    }
    
    @objc func stepperValueChanged(_ textField: UITextField) {
        if let text = textField.text, let value = Int(text) {
            stepperValue = value
        }
    }
    


}
