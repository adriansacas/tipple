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
    
    let tips = [
        "Headache": "Before: Stay hydrated by drinking water throughout the day.\n\nDuring: Alternate between alcoholic beverages and water. Consider choosing drinks with lower alcohol content.\n\nAfter: Drink more water before going to bed and consider taking a pain reliever if needed (but avoid acetaminophen, as it can be hard on the liver when combined with alcohol).",
        "Dehydration": "Before: Hydrate well before drinking, and consider consuming beverages with electrolytes.\n\nDuring: Alternate alcoholic drinks with water to stay hydrated.\n\nAfter: Drink water before going to bed and rehydrate the next day with water, sports drinks, or coconut water.",
        "Nausea": "Before: Eat a balanced meal before drinking.\n\nDuring: Pace yourself and avoid drinking on an empty stomach. Sip on ginger tea, which may help with nausea.\n\nAfter: Eat a light meal and consider ginger-based remedies or over-the-counter anti-nausea medication.",
        "Vomiting": "Before: Eat a substantial meal before drinking.\n\nDuring: Pace yourself, and if you feel nauseous, take a break from drinking.\n\nAfter: Rest and rehydrate with water or electrolyte drinks. If vomiting persists, seek medical attention.",
        "Diarrhea": "Before: Avoid spicy or greasy foods before drinking.\n\nDuring: Pace yourself and choose beverages with lower alcohol content.\n\nAfter: Eat bland foods and stay hydrated with water or electrolyte drinks.",
        "Indigestion": "Before: Avoid foods that are known to cause indigestion.\n\nDuring: Pace yourself and take breaks between drinks.\n\nAfter: Consider over-the-counter antacids if needed. Eat a light meal.",
        "Memory Loss": "Before: Know your limits and avoid excessive drinking.\n\nDuring: Pace yourself and be aware of how much you're consuming.\n\nAfter: Get adequate rest and allow time for your body to recover. Consider limiting alcohol intake in the future.",
        "Light Sensitivity": "Before: Be mindful of your sensitivity to light and plan accordingly.\n\nDuring: If possible, find a shaded or dimly lit area to reduce light exposure.\n\nAfter: Rest in a dark room if needed and avoid bright screens.",
        "Reduced Motor Skills": "Before: If you know you'll be drinking, plan for alternative transportation.\n\nDuring: Pace yourself and be aware of your level of intoxication.\n\nAfter: Don't drive if you're still feeling the effects of alcohol. Wait until you are sober.",
        "Blurred Vision": "Before: Be aware of any vision issues you may have and plan accordingly.\n\nDuring: Pace yourself and be cautious, especially if you experience blurred vision.\n\nAfter: If the blurred vision persists, seek medical attention.",
        "Slurred Speech": "Before: Be mindful of your speech patterns and pace yourself accordingly.\n\nDuring: Be aware of your speech and try to communicate clearly.\n\nAfter: Rest and allow time for the effects of alcohol to wear off."
      ]

    @IBOutlet weak var noDrinksLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var logsLabel: UILabel!
    
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
    }
    
    // Draws pie chart
    override func viewDidLayoutSubviews() {
        
        if beer + seltzer + wine + shots + cocktails != 0 {
            noDrinksLabel.isHidden = true
            
            pieChart.frame = CGRect(x: 0, y: 25, width: self.view.frame.size.width, height: 350)
            
            view2.addSubview(pieChart)
            
            var entries = [PieChartDataEntry]()
            
            // add data entries
            entries.append(PieChartDataEntry(value: Double(beer), label: "Beers"))
            entries.append(PieChartDataEntry(value: Double(seltzer), label: "Seltzers"))
            entries.append(PieChartDataEntry(value: Double(wine), label: "Wine"))
            entries.append(PieChartDataEntry(value: Double(shots), label: "Shots"))
            entries.append(PieChartDataEntry(value: Double(cocktails), label: "Cocktails"))
            
            // set colors
            let set = PieChartDataSet(entries: entries)
            let colorString = [NSUIColor(cgColor: UIColor(hex: "#3634A3").cgColor),
                                   NSUIColor(cgColor: UIColor(hex: "#D70015").cgColor),
                                   NSUIColor(cgColor: UIColor(hex: "#7D7AFF").cgColor),
                                   NSUIColor(cgColor: UIColor(hex: "#FF6961").cgColor),
                                   NSUIColor(cgColor: UIColor(hex: "#ffb861").cgColor)]
            set.colors = colorString
            
            let data = PieChartData(dataSet: set)
            pieChart.data = data
        }
    }
    
    func populateDrinks() {
        
        let drinks = session.getSessionDrinks().reversed()
        
        drinks.forEach { drink in
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
        var count = 1
        var sympTemp = ""
        var tipsTemp = "Tip #\(count): Drink responsibly!\n\n\n"
        for symp in symptoms {
            sympTemp += "\(symp)\n"
            let temp = tips[symp, default:""]
            if temp != "" {
                count += 1
                tipsTemp += "Tip #\(count): \(symp)\n\n\(temp)\n\n\n"
            }
        }
        
        if sympTemp != "" {
            symptomsLabel.text = sympTemp
        }
        
        tipsLabel.text = tipsTemp
    }
    
    func update(symptoms: [String]) {
        
        firestoreManager.updateSymptomsForSession(userID: self.userID!, sessionID: self.sessionID!, symptoms: symptoms) {
            error in if let error = error {
                print("Error updating symptoms: \(error)")
            }
        }
        
        self.symptoms = symptoms
        let otherVC = delegate as! update
        otherVC.updateSessions()
        
        populateSympAndTips()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SymptomsSegueIdentifier",
               let nextVC = segue.destination as? SymptomsViewController // typecasting
            {
                nextVC.delegate = self
                nextVC.sessionSymptoms = symptoms
            }
    }
    

}
