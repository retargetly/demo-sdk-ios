//
//  DashboardViewController.swift
//  RetargetlyDemo
//
//  Created by José Valderrama on 7/31/17.
//  Copyright © 2017 Retargetly. All rights reserved.
//

import UIKit
import Retargetly
import CoreLocation

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            let sdkBundle = Bundle(for: RManager.self)
            versionLabel.text = "Version: \(sdkBundle.versionNumber ?? "") (\(sdkBundle.buildNumber ?? ""))"
        }
    }
    @IBOutlet weak var sourceHashTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var responseTextView: UITextView! {
        didSet {
            responseTextView.layer.borderColor = UIColor.black.cgColor
            responseTextView.layer.borderWidth = 2
            responseTextView.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    final let sourceHashDev = "x9mfLt0ATihM0n0bI4PPuV9bbDNa1E3D"
    var config: RManagerConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRetargetlySDK()
    }
    
    private func initRetargetlySDK() {
        guard !indicator.isAnimating else { return }
        self.indicator.startAnimating()
        
        var sourceHash = sourceHashDev
        
        if let sourceHashValue = sourceHashTextField.text,
           !sourceHashValue.isEmpty {
            sourceHash = sourceHashValue
        }
        
        if config?.sourceHash != sourceHash {
            config = RManagerConfiguration(sourceHash: sourceHash,
                                           sendGeoData: true,
                                           forceGPS: true,
                                           sendLanguageEnabled: false,
                                           sendManufacturerEnabled: false,
                                           sendDeviceNameEnabled: false,
                                           sendWifiNameEnabled: false)
        }
        
        RManager.initiate(with: config) { [weak self] (error) in
            let message = "Initiate: \(error?.localizedDescription ?? "Succeed")\n"
            
            DispatchQueue.main.async {
                self?.responseTextView.text.append(message)
                self?.indicator.stopAnimating()
            }
            
            guard error == nil else {
                return
            }
            
            RManager.default?.rLocationManager?.delegate = self
            RManager.default?.delegate = self
        }
    }
    
    @IBAction func reconnectButtonTaped(_ sender: Any) {
        initRetargetlySDK()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        responseTextView.text = nil
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendAction()
    }
    
    fileprivate func sendAction() {
        guard !indicator.isAnimating else { return }
        
        guard let manager = RManager.default else {
            presentErrorAlert(with: "First reconnect with a valid source hash")
            return
        }
        
        guard let valueText = self.valueTextField.text, !valueText.isEmpty else {
            presentErrorAlert(with: "A value is required to send on event")
            return
        }
        
        view.endEditing(true)
        self.indicator.startAnimating()
        
        let value = ["aCustomValueField" : valueText]
        manager.track(value: value) { [weak self] (error) in
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
    
    // MARK: - Navigation
    
    @IBAction func backToDashboard(unwindSegue: UIStoryboardSegue) {
        guard let settings = unwindSegue.source as? SettingsTableViewController,
              let config = settings.config else {
            return
        }
        
        self.config = config
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settings = segue.destination as? SettingsTableViewController else {
            return
        }
        
        settings.config = config
    }
    
}

extension DashboardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == valueTextField {
            sendAction()
        }
        return true
    }
}

extension DashboardViewController: RLocationManagerDelegate {
    func rlocationManager(_ manager: CLLocationManager, didFailWith error: Error) {
        presentErrorAlert(with: error.localizedDescription)
    }
}

extension DashboardViewController: RManagerDelegate {
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
