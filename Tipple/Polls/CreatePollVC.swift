//
//  CreatePollVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/5/23.
//

import UIKit
import FirebaseAuth

class CreatePollVC: UITableViewController, PollsDelegateVC, UITextFieldDelegate {

    var prompt: String = ""
    var options: [String: Int] = [:]
    var multipleVotes: Bool = false
    var votersAddOptions: Bool = false
    var expirationDate: Date = Date()
    var voters: [String] = []
    
    let firestoreManager = FirestoreManager.shared
    var sections: [[String]] = []
    var switchCellLabels: [String] = ["Multiple votes", "Voters can add options"]
    weak var session: SessionInfo?
    weak var delegate: PollsDelegate?
    var currentUser: User?
    
    let promptCellIdentifier = "PromptCell"
    let optionCellIdentifier = "OptionCell"
    let addOptionCellIdentifier = "AddOptionCell"
    let switchCellIdentifier = "SwitchCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        sections = buildSections()
    }
    
    // Called when 'return' key pressed

    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getCurrentUser() {
        AuthenticationManager.shared.getCurrentUser(viewController: self) { user, error in
            if let error = error {
                // Errors are handled in AuthenticationManager
                print("Error retrieving user: \(error.localizedDescription)")
            } else if let user = user {
                // Successfully retrieved the currentUser
                self.currentUser = user
                // Do anything that needs the currentUser
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
    }
    
    func buildSections() -> [[String]] {
        var sections: [[String]] = []

        // Section 1: Prompt (1 cell)
        sections.append([promptCellIdentifier])

        // Section 2: Options
        var optionCells: [String] = []
        // Create 3 initial option cells
        for _ in 0..<3 {
            optionCells.append(optionCellIdentifier)
        }
        // Add the "Add Option" cell
        optionCells.append(addOptionCellIdentifier)
        sections.append(optionCells)

        // Section 3: Poll Settings
        sections.append([switchCellIdentifier, switchCellIdentifier])

        return sections
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let cellIdentifier = sections[section][row]

        switch cellIdentifier {
        case promptCellIdentifier:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PromptCell
            cell.textField.delegate = self
            return cell
        case optionCellIdentifier:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OptionCell
            cell.textField.delegate = self
            return cell
        case addOptionCellIdentifier:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        case switchCellIdentifier:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SwitchCell
            // Set the label text for the switch cell
            cell.label.text = switchCellLabels[indexPath.row]
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        }
    }

    // Slide delete options
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if indexPath.section == 1 && indexPath.row < sections[1].count - 1 {
////                options.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Insert a new OptionCell when the AddOptionCell is tapped
        if indexPath.section == 1, indexPath.row == sections[1].count - 1 {
            insertNewOptionCell()
        }
    }
    
    // Insert a new OptionCell in the second to last position in section 2
    func insertNewOptionCell() {
        // Create a new option cell and add it to the second-to-last position in Section 2
        sections[1].insert(optionCellIdentifier, at: sections[1].count - 1)

        // Insert the cell in the table view
        let newCellIndexPath = IndexPath(row: sections[1].count - 2, section: 1)
        tableView.insertRows(at: [newCellIndexPath], with: .automatic)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let currentUser = currentUser else {
            return
        }
        
        // Get the prompt value
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PromptCell {
            if let text = cell.textField.text {
                prompt = text
            } 
            if prompt.isEmpty {
                AlertUtils.showAlert(title: "Invalid Poll", message: "Enter a valid prompt.", viewController: self)
                return
            }
        }
        
        // Get the poll options
        for row in 0..<sections[1].count {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 1)) as? OptionCell {
                if let text = cell.textField.text {
                    // add the option only if it is not empty
                    if !text.isEmpty {
                        options[text] = 0
                    }
                }
            }
        }
        
        if options.count < 2 {
            AlertUtils.showAlert(title: "Invalid Poll", message: "Enter at least two options.", viewController: self)
            return
        }
        
        // Get the poll settings
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SwitchCell {
            multipleVotes = cell.switchSlider.isOn
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? SwitchCell {
            votersAddOptions = cell.switchSlider.isOn
        }
        
        let poll = Poll(prompt: prompt, options: options, multipleVotes: multipleVotes, votersAddOptions: votersAddOptions, expiration: expirationDate, createdBy: currentUser.uid, voters: voters)
        
        firestoreManager.createPoll(userID: currentUser.uid, prompt: prompt, options: options, multipleVotes: multipleVotes, votersAddOptions: votersAddOptions, expiration: expirationDate, voters: voters) { pollID, error in
            if let error = error {
                // Handle the error
                print("Error creating poll: \(error)")
            } else if let pollID = pollID {
                // Poll created successfully
                self.updateSession(pollID: pollID)
                
                self.delegate?.didCreateNewPoll(poll)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func updateSession(pollID: String) {
        guard let currentUser = currentUser,
              let session = session,
              let sessionDocID = session.sessionDocID else {
            return
        }
        
        if session.polls == nil {
            session.polls = []
        }
       
        session.polls?.append(pollID)
        let fields = ["polls": session.polls as Any] as [String : Any]
        
        // TODO: Consider using FieldValue.arrayUnion(valuesToAdd) instead of passing all the current pollIDs
        firestoreManager.updateGroupSession(userID: currentUser.uid, sessionID: sessionDocID, fields: fields) { error in
            if let error = error {
                print("Error updating group session: \(error.localizedDescription)")
            } else {
                print("Group session updated successfully.")
            }
        }
    }
}
