//
//  AlertUtils.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/17/23.
//

import UIKit

/*
 Display an alert with an OK action so the user can acknowledge it.
 
 Example usage in a view controller
 AlertUtils.showAlert(title: "Error", message: "Something went wrong.", viewController: self)
 */
class AlertUtils {
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
