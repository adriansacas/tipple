//
//  PollsVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/5/23.
//

import UIKit

class PollsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    let pollDetailsSegueIdentifier = "PollDetailsSegueIdentifier"
    let firestoreManager = FirestoreManager.shared
    var polls: [Poll] = []
//    TODO: pass the session info from the parent view
    var sessionInfo: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getPolls()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return polls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure each cell in the table view.
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        let poll = polls[row]
        cell.textLabel?.text = poll.prompt
        
        return cell
    }
    
    // Swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pollToDelete = polls[indexPath.row]
            if let pollIDToDelete = pollToDelete.pollID {
                firestoreManager.deletePoll(pollID: pollIDToDelete) { error in
                    if let error = error {
                        print("Error deleting poll: \(error)")
                    } else {
                        // Poll deleted successfully
                        self.polls.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            } else {
                print("Error retrieving poll ID")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == pollDetailsSegueIdentifier {
            if let pollVC = segue.destination as? PollVC,
               let pollIndex = tableView.indexPathForSelectedRow?.row {
//                pollVC.delegate = self
                pollVC.poll = polls[pollIndex]
            }
        }
    }
    
    func getPolls() {
//        TODO: Uncomment this after implementing passing sessioninfo from parent view
//        guard let sessionInfo = sessionInfo else {
//            // Handle the case where sessionInfo is nil
//            return
//        }
        
//        firestoreManager.getPolls(pollIDs: sessionInfo.polls) { [weak self] (polls, error) in
        firestoreManager.getPolls(pollIDs: ["nrHqbeHG62CiCZKMsF9v"]) { [weak self] (polls, error) in
            if let error = error {
                print("Error fetching polls: \(error)")
            } else if let polls = polls {
                // Update the polls array and refresh the table view
                self?.polls = polls
                self?.tableView.reloadData()
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
            }
        }
    }
}
