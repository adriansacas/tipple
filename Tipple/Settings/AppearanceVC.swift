//
//  AppearanceVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/28/23.
//

import UIKit

class AppearanceVC: UITableViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var partyModeSwitch: UISwitch!
    let partyModeView = PartyModeAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setSwitchState()
    }
    
    @IBAction func toggleDarkMode(_ sender: UISwitch) {
        let desiredStyle: UIUserInterfaceStyle = sender.isOn ? .dark : .light

        if #available(iOS 13.0, *) {
            UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .forEach { windowScene in
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = desiredStyle
                    }
                }
        } else {
            // Fallback on earlier versions
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = desiredStyle
        }

        // Save the setting in UserDefaults
        UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")
    }
    
    @IBAction func togglePartyMode(_ sender: UISwitch) {
        if sender.isOn {
            partyModeView.frame = self.view.bounds
            self.view.addSubview(partyModeView)
            partyModeView.startAnimation()
        } else {
            partyModeView.stopPartyMode()
        }
        UserDefaults.standard.set(sender.isOn, forKey: "partyModeEnabled")
    }
    
    func setSwitchState() {
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        partyModeSwitch.isOn = UserDefaults.standard.bool(forKey: "partyModeEnabled")
    }

}
