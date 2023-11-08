//
//  PollsVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/5/23.
//

import UIKit
import FirebaseAuth

protocol PollsDelegate: AnyObject {
    func didCreateNewPoll(_ newPoll: Poll)
    func didVote()
}

protocol PollsDelegateVC: UIViewController {
    var session: SessionInfo? { get set }
    var delegate: PollsDelegate? { get set }
}

class PollsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, PollsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    let pollDetailsSegueIdentifier = "PollDetailsSegueIdentifier"
    let createPollSegueIdentifier = "CreatePollSegueIdentifier"
    let pollResultsSegueIdentifier = "PollResultsSegueIdentifier"
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
    
    func didCreateNewPoll(_ newPoll: Poll) {
        getPolls()
    }
    
    func didVote() {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poll = polls[indexPath.row]
        let user = Auth.auth().currentUser
        
        if poll.voters.contains(user!.uid) { // has voted. show results
            performSegue(withIdentifier: pollResultsSegueIdentifier, sender: self)
        } else {
            performSegue(withIdentifier: pollDetailsSegueIdentifier, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == pollDetailsSegueIdentifier {
            if let pollVoteVC = segue.destination as? PollVoteVC,
               let pollIndex = tableView.indexPathForSelectedRow?.row {
//                TODO: Consider sendint the pollID instead so that the PollVote and PollResults are forced to retrieve the poll from Firestore and get the latests data
                pollVoteVC.poll = polls[pollIndex]
                pollVoteVC.delegate = self
            }
        } else if segue.identifier == createPollSegueIdentifier {
            if let createPollVC = segue.destination as? CreatePollVC {
                createPollVC.delegate = self
                createPollVC.session = self.session
            }
        } else if segue.identifier == pollResultsSegueIdentifier {
            if let pollResultsVC = segue.destination as? PollResultsVC,
                let pollIndex = tableView.indexPathForSelectedRow?.row {
                    pollResultsVC.poll = polls[pollIndex]
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
