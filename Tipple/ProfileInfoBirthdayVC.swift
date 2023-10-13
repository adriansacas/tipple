//
//  ProfileInfoBirthdayVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit

class ProfileInfoBirthdayVC: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a Calendar instance and define the initial date
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2000
        dateComponents.month = 1
        dateComponents.day = 1

        // Set the initial date for the date picker
        if let initialDate = calendar.date(from: dateComponents) {
            datePicker.date = initialDate
        }
    }

}
