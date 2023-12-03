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
    
    // Lets the user know their session expired and they need to sign in again before sending them back to the login page
    static func showSessionExpiredAlert(viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "LoginRegistrationHome", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        
        let alertController = UIAlertController(
            title: "Session Expired",
            message: "Looks like your session expired. Please sign back in.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            // send to login screen
            defaults.set(false, forKey: "tippleStayLoggedIn")
            viewController.present(destinationVC, animated: true)
        }
        
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        alertController.addAction(action)
        viewController.present(alertController, animated: true)
    }
    
    // Let the user know they need to confirm their new email address before sending them back to the login page
    static func showNeedEmailConfirmationAlert(viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "LoginRegistrationHome", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        
        let alertController = UIAlertController(
            title: "Email Update",
            message: "Check your inbox to confirm your new email address and sign back in.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            // send to login screen
            defaults.set(false, forKey: "tippleStayLoggedIn")
//            viewController.navigationController?.dismiss(animated: true)
            viewController.navigationController?.popToRootViewController(animated: false)
            viewController.present(destinationVC, animated: true)
//            viewController.navigationController?.pushViewController(destinationVC, animated: true, )
        }
        
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        alertController.addAction(action)
        viewController.present(alertController, animated: true)
    }
}
