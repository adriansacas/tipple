//
//  ProfileInfoGenderVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit

class ProfileInfoGenderVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    let textCellIdentifier = "TextCell"
    let tableFields: [String] = ["Man", "Woman", "Non-binary"]
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initialSelectedIndexPath()
    }
    
    func initialSelectedIndexPath() {
//        TODO: Get gender from firebase
        selectedIndexPath = IndexPath(row: 0, section: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = tableFields[row]
        
        // Checkmark setup
        if selectedIndexPath == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the previously selected cell
        if let selectedIndexPath = selectedIndexPath {
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        }
        
        // Update the selectedIndexPath
        selectedIndexPath = indexPath
        
        // Set the checkmark for the newly selected cell
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    
}
