//
//  DayViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 10/14/23.
//

import UIKit
import DGCharts

protocol updateSymptoms {
    func update(symptoms:[String])
}

class DayViewController: UIViewController, updateSymptoms, ChartViewDelegate {
    
    let tips = ["Headache" : "Taking Aspirin or Ibuprofen can help alieviate headaches, but stay away from Tylenol!",
                "Dehydration" : "Acohol promotes urination, so make sure to drink plenty of water before, during, and after drinking",
                "Nausea" : "Eat some bread or cracker! Carbs help absorb any alcohol left in the stomach to combat nausea",
                "Slurred speech" : "Drinking on an empty stomach can cause the alcohol to be absorbed in blood stream faster, make sure to eat before!",
                "Vomiting" : "Drinking in moderation can help prevent adverse effects"]
    
    var scrollView: UIScrollView!
    
    @IBOutlet weak var titleLabel: UILabel!
//
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!
//    @IBOutlet weak var logsLabel: UILabel!
//    @IBOutlet weak var beersCounter: UILabel!
//    @IBOutlet weak var seltzerCounter: UILabel!
    @IBOutlet weak var wineCounter: UILabel!
    @IBOutlet weak var shotsCOunter: UILabel!
    @IBOutlet weak var cocktailsCounter: UILabel!
    
    let logTextCellIdentifier = "LogCell"
    let symptomsTextCellIdentifier = "SymptomsCell"
    
    var session:SessionInfo = SessionInfo()
    var symptoms:[String] = ["No symptoms logged yet"]
    var logs:String = ""
    
    var delegate:UIViewController?
    
    var pieChart = PieChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        titleLabel.text = dateFormatter.string(from: session.getStartTime())
        self.title = session.getName()
        
//        scrollView = UIScrollView(frame: view.bounds)
//        view.addSubview(scrollView)
        
        pieChart.delegate = self
        
        // symptoms = session!.getSymptoms() beta release
        
        // populateDrinks()
        populateSympAndTips()
    }
    
    override func viewDidLayoutSubviews() {
        pieChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        pieChart.center = view.center
        
        view.addSubview(pieChart)
        
        var entries = [ChartDataEntry]()
        
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
        }
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
            
//            if drink.getType() == "Cocktail" {
//                logs += "\(drink.getTimestamp())\t\t\t\t\(drink.type)\t\t\t\t\(drink.getBAC())\n"
//            } else {
//                logs += "\(drink.getTimestamp())\t\t\t\t\(drink.type)\t\t\t\t\t\(drink.getBAC())\n"
//            }
            
            
        }
        
//        beersCounter.text = "\(beer)"
//        seltzerCounter.text = "\(seltzer)"
//        wineCounter.text = "\(wine)"
//        shotsCOunter.text = "\(shots)"
//        cocktailsCounter.text = "\(cocktails)"
//        
//        logsLabel.text = logs
        
    }
    
    func populateSympAndTips() {
        var sympTemp = ""
        var tipsTemp = ""
        for symp in symptoms {
            sympTemp += "\(symp)\n"
            tipsTemp += "\(tips[symp, default:""])\n"
        }
        symptomsLabel.text = sympTemp
        tipsLabel.text = tipsTemp
    }
    
    func update(symptoms: [String]) {
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
