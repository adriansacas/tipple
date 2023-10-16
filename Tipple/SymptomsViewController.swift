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
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        var selectedSymp = [String]()
        let cells = self.tableView.visibleCells

        for cell in cells {
            if cell.isSelected == true {
                selectedSymp.append((cell.textLabel?.text)!)
            }
        }
        print(selectedSymp)
        
    }
    
    

}
