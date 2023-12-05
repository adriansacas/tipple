//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth

class QRScannerController: UIViewController {
    
    @IBOutlet var messageLabel:UILabel!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let firestoreManager = FirestoreManager.shared

    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(simulator)

        // Create an instance variable to store the user-entered sessionID
        var enteredSessionID: String?

        // Create a UIAlertController with a text field
        let alertController = UIAlertController(title: "Enter Session ID\n(TA ACCESS ONLY)", message: "Please enter the session ID:", preferredStyle: .alert)

        // Add a text field to the alert controller
        alertController.addTextField { textField in
            textField.placeholder = "Session ID"
        }

        // Add actions to the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            // Dismiss the view controller when the "Cancel" button is tapped
            self?.dismiss(animated: true, completion: nil)
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            // Retrieve the entered sessionID from the text field
            enteredSessionID = alertController.textFields?.first?.text
            
            // Check if the sessionID is empty
            guard let sessionID = enteredSessionID, !sessionID.isEmpty else {
                // Show an error alert for empty session ID
                let emptyIDAlert = UIAlertController(title: "Error", message: "Session ID cannot be empty.", preferredStyle: .alert)
                emptyIDAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(emptyIDAlert, animated: true, completion: nil)
                return
            }
            
            // Validate the sessionID and dismiss or show an error alert
            self?.firestoreManager.validateSession(sessionID: sessionID) { isValid, error in
                if isValid {
                    // Session is valid, perform the segue
                    self?.messageLabel.text! = sessionID
                    self?.performSegue(withIdentifier: "qrToQuestionSegue", sender: nil)
                } else {
                    // Session is invalid, show an error alert and dismiss the view controller
                    let errorAlert = UIAlertController(title: "Invalid Session", message: "The entered session ID is not valid.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self?.dismiss(animated: true, completion: nil)
                    })
                    self?.present(errorAlert, animated: true, completion: nil)
                }
            }
        }

        // Add actions to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)

        #endif



        checkCameraAccess { granted in
            if granted {
                // Camera access is granted, proceed with your logic
                // Get the back-facing camera for capturing videos
                guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                    print("Failed to get the camera device")
                    return
                }
                
                do {
                    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                    let input = try AVCaptureDeviceInput(device: captureDevice)
                    
                    // Set the input device on the capture session.
                    self.captureSession.addInput(input)
                    
                    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                    let captureMetadataOutput = AVCaptureMetadataOutput()
                    self.captureSession.addOutput(captureMetadataOutput)
                    
                    // Set delegate and use the default dispatch queue to execute the call back
                    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
                    //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                    
                } catch {
                    // If any error occurs, simply print it out and don't continue any more.
                    print(error)
                    return
                }
                
                // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.view.layer.bounds
                self.view.layer.addSublayer(self.videoPreviewLayer!)
                
                // Start video capture.
                self.captureSession.startRunning()
                
                // Move the message label and top bar to the front
                self.view.bringSubviewToFront(self.messageLabel)
                
                // Initialize QR Code Frame to highlight the QR code
                self.qrCodeFrameView = UIView()
                
                if let qrCodeFrameView = self.qrCodeFrameView {
                    qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                    qrCodeFrameView.layer.borderWidth = 2
                    self.view.addSubview(qrCodeFrameView)
                    self.view.bringSubviewToFront(qrCodeFrameView)
                }
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
    func checkCameraAccess(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
            DispatchQueue.main.async {
                completion(false)
            }
        case .restricted:
            print("Restricted, device owner must approve")
            DispatchQueue.main.async {
                completion(false)
            }
        case .authorized:
            print("Authorized, proceed")
            DispatchQueue.main.async {
                completion(true)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("Permission denied")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(alertController, animated: true)
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "qrToQuestionSegue",
           let destination = segue.destination as? QuestionnaireVC {
            destination.sessionType = "Join"
            destination.sessionID = messageLabel.text!
        }
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let sessionID = metadataObj.stringValue {
                self.messageLabel.text = metadataObj.stringValue
                firestoreManager.validateSession(sessionID: sessionID) { isValid, error in
                    if isValid {
                        // Session is valid, perform the segue
                        self.performSegue(withIdentifier: "qrToQuestionSegue", sender: nil)
                    } else {
                        let alert = UIAlertController(title: "Invalid Session", message: "The QR code does not correspond to a valid session.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
