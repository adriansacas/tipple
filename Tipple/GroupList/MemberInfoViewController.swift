//
//  MemberInfoViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 11/5/23.
//

import UIKit
import FirebaseAuth

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreManager = FirestoreManager.shared
    let textCellIdentifier = "TextCell"
    
    var keys:[String] = []
    var user:[String:Any]?
    var delegate:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        for key in user!.keys {
            if(key != "name") {
                keys.append(key)
            }
        }
        nameField.text = user!["name"] as? String
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath) as! PersonCell
    
        let row = indexPath.row
        
        let key = String(keys[row])
        
        cell.keyField.text = key
        cell.valueField.text = user![key] as? String
        
        return cell
    }

}

class PersonCell: UITableViewCell {
    @IBOutlet weak var keyField: UILabel!
    @IBOutlet weak var valueField: UILabel!
    
}
