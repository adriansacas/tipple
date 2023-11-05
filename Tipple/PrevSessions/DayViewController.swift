//
//  DayViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 10/14/23.
//

import UIKit
import DGCharts
import FirebaseAuth

protocol updateSymptoms {
    func update(symptoms:[String])
}

class DayViewController: UIViewController, updateSymptoms, ChartViewDelegate {
    
    let tips = ["Headache" : "Taking Aspirin or Ibuprofen can help alieviate headaches, but stay away from Tylenol!",
                "Dehydration" : "Acohol promotes urination, so make sure to drink plenty of water before, during, and after drinking",
                "Nausea" : "Eat some bread or cracker! Carbs help absorb any alcohol left in the stomach to combat nausea",
                "Slurred speech" : "Drinking on an empty stomach can cause the alcohol to be absorbed in blood stream faster, make sure to eat before!",
                "Vomiting" : "Drinking in moderation can help prevent adverse effects"]

    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var logsLabel: UILabel!
    
    let logTextCellIdentifier = "LogCell"
    let symptomsTextCellIdentifier = "SymptomsCell"
    let firestoreManager = FirestoreManager.shared
    
    var session:SessionInfo = SessionInfo()
    var sessionID:String?
    var symptoms:[String] = []
    var userID:String?
    var logs:String = ""
    
    var delegate:UIViewController?
    
    var pieChart = PieChartView()
    
    var beer = 0
    var seltzer = 0
    var wine = 0
    var shots = 0
    var cocktails = 0
    
    @IBOutlet weak var view2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        self.title = "\(dateFormatter.string(from: session.getStartTime())) - \(session.getName())"
        
        if let userID = Auth.auth().currentUser?.uid {
            self.userID = userID
        } else {
            print("Error fetching user ID from currentUser")
        }
        
        pieChart.delegate = self
        
        symptoms = session.getAllSymptoms()
        
        populateDrinks()
        populateSympAndTips()
        
        print("session ID: \(sessionID!)")
        print("session id straight from session: \(String(describing: session.sessionDocID))")
    }
    
    override func viewDidLayoutSubviews() {
        pieChart.frame = CGRect(x: 0, y: 25, width: self.view.frame.size.width, height: 350)
        
        view2.addSubview(pieChart)
        
        var entries = [ChartDataEntry]()
        
        entries.append(ChartDataEntry(x: Double(beer), y: Double(beer)))
        entries.append(ChartDataEntry(x: Double(seltzer), y: Double(seltzer)))
        entries.append(ChartDataEntry(x: Double(wine), y: Double(wine)))
        entries.append(ChartDataEntry(x: Double(shots), y: Double(shots)))
        entries.append(ChartDataEntry(x: Double(cocktails), y: Double(cocktails)))
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.colorful()
        let data = PieChartData(dataSet: set)
        pieChart.data = data
    }
    
    func populateDrinks() {
            
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
            
            logsLabel.text = logs
        
    }
    
    func populateSympAndTips() {
        var sympTemp = ""
        var tipsTemp = "- Drink responsibly!\n\n"
        for symp in symptoms {
            sympTemp += "\(symp)\n"
            let temp = tips[symp, default:""]
            if temp != "" {
                tipsTemp += "- \(temp)\n\n"
            }
        }
        
        if sympTemp != "" {
            symptomsLabel.text = sympTemp
        }
        
        tipsLabel.text = tipsTemp
    }
    
    func update(symptoms: [String]) {
        var temp:[String] = []
        
        for symp in symptoms {
            if !self.symptoms.contains(symp) {
                temp.append(symp)
            }
        }
        
        if !temp.isEmpty {
            firestoreManager.updateSymptomsForSession(userID: self.userID!, sessionID: self.sessionID!, symptoms: temp) {
                error in if let error = error {
                    print("Error updating symptoms: \(error)")
                }
            }
        }
        
        self.symptoms = symptoms
        
        populateSympAndTips()
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
