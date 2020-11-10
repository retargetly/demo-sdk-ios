//
//  FirstViewController.swift
//  RetargetlyDemo
//
//  Created by José Valderrama on 7/31/17.
//  Copyright © 2017 Retargetly. All rights reserved.
//

import UIKit
import Retargetly
import CoreLocation

class FirstViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            let sdkBundle = Bundle(for: RManager.self)
            versionLabel.text = "Version: \(sdkBundle.versionNumber ?? "") (\(sdkBundle.buildNumber ?? ""))"
        }
    }
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var responseTextView: UITextView! {
        didSet {
            responseTextView.layer.borderColor = UIColor.black.cgColor
            responseTextView.layer.borderWidth = 2
            responseTextView.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initRetargetlySDK()
    }
    
    private func initRetargetlySDK() {
        let sourceHash = "x9mfLt0ATihM0n0bI4PPuV9bbDNa1E3D"
        
        RManager.initiate(sourceHash: sourceHash) { (error) in
            print("RManager.initiate ", error as Any)
            RManager.default.rLocationManager?.delegate = self
            RManager.default.delegate = self
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendAction()
    }
    
    fileprivate func sendAction() {
        guard !indicator.isAnimating else { return }
        
        guard let valueText = self.valueTextField.text, !valueText.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "A value is required to send on event", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        self.valueTextField.resignFirstResponder()
        self.indicator.startAnimating()
        
        let value = ["aCustomValueField" : valueText]
        RManager.default.track(value: value) {[weak self] (error) in
            DispatchQueue.main.async {
                self?.indicator.stopAnimating()
                guard let strongSelf = self else { return }
                let text = "CUSTOM EVENT - done with error: " + String(describing: error)
                strongSelf.responseTextView.text.append("\(text)\n")
            }
        }
    }
    
    fileprivate func presentErrorAlert(with message: String? = nil) {
        let alert = UIAlertController(title: "Error", message: message ?? "An unknown error has occurred", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension FirstViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendAction()
        return true
    }
}

extension FirstViewController: RLocationManagerDelegate {
    func rLocationManager(_ manager: CLLocationManager, couldNotInitBecause error: NSError?) {
        presentErrorAlert(with: error?.localizedDescription)
    }
}

extension FirstViewController: RManagerDelegate {
    func rManager(_ manager: RManager, didSendActionWith message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.responseTextView.text.append(message + "\n")
            
            
            if strongSelf.responseTextView.text.count > 0 {
                let location = strongSelf.responseTextView.text.count - 1
                let bottom = NSMakeRange(location, 1)
                strongSelf.responseTextView.scrollRangeToVisible(bottom)
            }
        }
    }
}
