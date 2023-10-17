//
//  SymptomsViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 10/14/23.
//

import UIKit

public let symptoms = [
    "Headache", "Dehydration", "Nausea", "Vomiting", "Diarrhea", "Indigestion",
    "Memory loss", "Light sensitivity", "Reduced motor skills", "Blurred vision",
    "Slurred speech"
]

class SymptomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate:UIViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    var sessionSymptoms:[String] = []
    var selected = [false, false, false, false, false, false, false, false, false, false, false]
    
    let textCellIdentifier = "TextCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // set symptoms
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
    
        let row = indexPath.row
        cell.textLabel?.text = symptoms[row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row, and instead, show the state with a checkmark.
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // Update the selected item to indicate whether the user packed it or not.
        let current = selected[indexPath.row]
        let newItem = !current
        selected.remove(at: indexPath.row)
        selected.insert(newItem, at: indexPath.row)
        
        // Show a check mark next to packed items.
        if newItem {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let otherVC = delegate as! updateSymptoms
        
        var selectedSymp = [String]()

        var i = 0
        for index in selected {
            if index {
                selectedSymp.append(symptoms[i])
            }
            i += 1
        }
        otherVC.update(symptoms: selectedSymp)
        
    }
    

}
