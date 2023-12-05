//
//  InviteCodeViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class InviteCodeVC: UIViewController {

    @IBOutlet weak var sessionNameTextLabel: UILabel!
    @IBOutlet weak var sessionEndDateTimeLabel: UILabel!
    @IBOutlet weak var inviteCodeImageView: UIImageView!
    
    var sessionName: String = ""
    var endDate: Date = Date()
    var sessionID: String = ""
    var groupQRCode: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteCodeImageView.image = groupQRCode
        
        self.sessionNameTextLabel.text = sessionName

        // Display current session name and end date/time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: endDate)
        self.sessionEndDateTimeLabel.text = formattedDate
        
        
        // Create a UILabel for the sessionID
        #if targetEnvironment(simulator)

        let sessionIDLabel = UILabel()
        sessionIDLabel.text = "Session ID: \(sessionID)"
        sessionIDLabel.textAlignment = .center
        sessionIDLabel.textColor = .black
        sessionIDLabel.font = UIFont.systemFont(ofSize: 18.0)
        sessionIDLabel.numberOfLines = 0 // Allow multiple lines if needed

        // Add the UILabel below the QRCode
        view.addSubview(sessionIDLabel)

        // Position the UILabel below the QRCode
        let labelHeight: CGFloat = 50.0
        sessionIDLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sessionIDLabel.leadingAnchor.constraint(equalTo: inviteCodeImageView.leadingAnchor),
            sessionIDLabel.trailingAnchor.constraint(equalTo: inviteCodeImageView.trailingAnchor),
            sessionIDLabel.topAnchor.constraint(equalTo: inviteCodeImageView.bottomAnchor),
            sessionIDLabel.heightAnchor.constraint(equalToConstant: labelHeight)
        ])
        #endif
    }
    
    //TODO: make QR image bigger when clicked on
}
