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
    //@IBOutlet weak var logTableView: UITableView!
    //@IBOutlet weak var symptomsTableView: UITableView!
    
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
    var symptoms:[String] = ["Headache"]
    var logs:String = "10:00PM\t\t\t\tBeer\t\t\t\t\t0.05%"
    
    var delegate:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        titleLabel.text = dateFormatter.string(from: session.getStartTime())
        
        // symptoms = session!.getSymptoms()
        
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
            if drink.type == "Beer" {
                beer += 1
            } else if drink.type == "Seltzer" {
                seltzer += 1
            } else if drink.type == "Wine" {
                wine += 1
            } else if drink.type == "Shot" {
                shots += 1
            } else if drink.type == "Cocktail" {
                cocktails += 1
            }
            logs += "\(drink.getTimestamp())\t\t\t\t\(drink.type)\t\t\t\t\t\(drink.getBAC())%\n"
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
                nextVC.sessionSymptoms = symptoms
            }
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var result = 0
//        if tableView == logTableView {
//            result = logs.count
//        } else if tableView == symptomsTableView {
//            result = symptoms.count
//        }
//        return result
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        var identifier = tableView == logTableView ? logTextCellIdentifier : symptomsTextCellIdentifier
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath)
//
//        let row = indexPath.row
//
//        var newText = tableView == logTableView ? logs[row] : symptoms[row]
//
//        cell.textLabel?.text = newText
//
//        return cell
//    }
    

}
