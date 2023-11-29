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
            startPartyMode()
        } else {
            stopPartyMode()
        }
        UserDefaults.standard.set(sender.isOn, forKey: "partyModeEnabled")
    }
    
    func setSwitchState() {
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        partyModeSwitch.isOn = UserDefaults.standard.bool(forKey: "partyModeEnabled")
    }
    
    func startPartyMode() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)

        let cell = CAEmitterCell()
        cell.birthRate = 10
        cell.lifetime = 20.0
        cell.velocity = 300
        cell.velocityRange = 100
        cell.emissionLongitude = CGFloat.pi
        cell.spinRange = 5
        cell.scale = 0.05
        cell.scaleRange = 0.3
        cell.contents = UIImage(named: "confetti")?.cgImage

        emitter.emitterCells = [cell]

        view.layer.addSublayer(emitter)
    }
    
    func stopPartyMode() {
        view.layer.sublayers?.filter { $0 is CAEmitterLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    func imageFromEmoji(_ emoji: String, size: CGSize) -> UIImage? {
        let size = size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        emoji.draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: size.height)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }


}
