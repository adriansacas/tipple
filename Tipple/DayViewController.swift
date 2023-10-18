//
//  DayViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 10/14/23.
//

import UIKit
//  UITableViewDataSource

protocol updateSymptoms {
    func update(symptoms:[String])
}

class DayViewController: UIViewController, updateSymptoms {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var logsLabel: UILabel!
    @IBOutlet weak var beersCounter: UILabel!
    @IBOutlet weak var seltzerCounter: UILabel!
    @IBOutlet weak var wineCounter: UILabel!
    @IBOutlet weak var shotsCOunter: UILabel!
    @IBOutlet weak var cocktailsCounter: UILabel!
    
    let logTextCellIdentifier = "LogCell"
    let symptomsTextCellIdentifier = "SymptomsCell"
    
    var session:SessionInfo = SessionInfo()
    var symptoms:[String] = ["No symptoms logged yet"]
    var logs:String = ""
    
    var delegate:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        titleLabel.text = dateFormatter.string(from: session.getStartTime())
        self.title = session.getName()
        
        // symptoms = session!.getSymptoms() beta release
        
        populateDrinks()
        populateSymptoms()
    }
    
    func populateDrinks() {
        var beer = 0
        var seltzer = 0
        var wine = 0
        var shots = 0
        var cocktails = 0
        
        session.getSessionDrinks().forEach { drink in
            if drink.getType() == "Beer" {
                beer += 1
            } else if drink.getType() == "Seltzer" {
                seltzer += 1
            } else if drink.getType() == "Wine" {
                wine += 1
            } else if drink.getType() == "Shot" {
                shots += 1
            } else if drink.getType() == "Cocktail" {
                cocktails += 1
            }
            
            if drink.getType() == "Cocktail" {
                logs += "\(drink.getTimestamp())\t\t\t\t\(drink.type)\t\t\t\t\(drink.getBAC())\n"
            } else {
                logs += "\(drink.getTimestamp())\t\t\t\t\(drink.type)\t\t\t\t\t\(drink.getBAC())\n"
            }
            
        }
        
        beersCounter.text = "\(beer)"
        seltzerCounter.text = "\(seltzer)"
        wineCounter.text = "\(wine)"
        shotsCOunter.text = "\(shots)"
        cocktailsCounter.text = "\(cocktails)"
        
        logsLabel.text = logs
        
    }
    
    func populateSymptoms() {
        var sympTemp = ""
        for symp in symptoms {
            sympTemp += "\(symp)\n"
        }
        symptomsLabel.text = sympTemp
    }
    
    func update(symptoms: [String]) {
        self.symptoms = symptoms
        populateSymptoms()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SymptomsSegueIdentifier",
               let nextVC = segue.destination as? SymptomsViewController // typecasting
            {
                nextVC.delegate = self
                nextVC.sessionSymptoms = symptoms // beta release add to firebase
            }
    }
    

}
