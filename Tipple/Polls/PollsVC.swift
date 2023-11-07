//
//  PollsVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/5/23.
//

import UIKit
import FirebaseAuth

class PollsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    let pollDetailsSegueIdentifier = "PollDetailsSegueIdentifier"
    let createPollSegueIdentifier = "CreatePollSegueIdentifier"
    let firestoreManager = FirestoreManager.shared
    var polls: [Poll] = []
//    TODO: change to sessionID, get the session info, pass the session id from the parent view
//    var sessionID = "uyvaVnIENbZHo00Q3ZBR"
    var sessionID: String?
    var session: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        getSession()
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
        } else if segue.identifier == createPollSegueIdentifier {
            if let createPollVC = segue.destination as? CreatePollVC {
                createPollVC.session = self.session
            }
        }
    }
    
    func getSession() {
        guard let sessionID = sessionID else {
            return
        }
        let user = Auth.auth().currentUser
        
        firestoreManager.getSessionInfo(userID: user!.uid, sessionDocumentID: sessionID) { sessionInfo, error in
            if let error = error {
                print("Error fetching session information: \(error.localizedDescription)")
            } else if let sessionInfo = sessionInfo {
                self.session = sessionInfo
                self.getPolls()
            }
        }
    }
    
    func getPolls() {
        guard let session = session,
              let pollsIDs = session.polls else {
            return
        }
        
        //TODO: modify sessionInfo and getSessionInfo to get polls
        firestoreManager.getPolls(pollIDs: pollsIDs) { [weak self] (polls, error) in
//        firestoreManager.getPolls(pollIDs: ["nrHqbeHG62CiCZKMsF9v"]) { [weak self] (polls, error) in
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
