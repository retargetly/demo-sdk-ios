//
//  SettingsTableViewController.swift
//  RetargetlyDemo
//
//  Created by José Valderrama on 12/01/2021.
//  Copyright © 2021 Retargetly. All rights reserved.
//

import UIKit
import Retargetly

class SettingsTableViewController: UITableViewController {
    
    private final let cellIdentifier = "SwitchTableViewCell"
    var config: RManagerConfiguration!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: cellIdentifier, bundle: .main), forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SwitchTableViewCell else {
            return UITableViewCell()
        }
        
        let tuple: (title: String, on: Bool)
        
        switch indexPath.row {
        case 0:
            tuple = ("Send geo data", config.sendGeoData)
        case 1:
            tuple = ("Force GPS", config.forceGPS)
        case 2:
            tuple = ("Send language", config.sendLanguageEnabled)
        case 3:
            tuple = ("Send manufacturer", config.sendManufacturerEnabled)
        case 4:
            tuple = ("Send device name", config.sendDeviceNameEnabled)
        default:
            tuple = ("Send Wifi name", config.sendWifiNameEnabled)
        }
        
        cell.configure(title: tuple.title, on: tuple.on)
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var boolValues = [Bool]()
        let range = 0..<6
        for row in range {
            guard let switchCell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SwitchTableViewCell
            else { continue }
            
            boolValues.append(switchCell.switchControl.isOn)
        }
        
        guard boolValues.count == 6 else { return }
              
        config = RManagerConfiguration(
            sourceHash: config.sourceHash,
            sendGeoData: boolValues[0],
            forceGPS: boolValues[1],
            sendLanguageEnabled: boolValues[2],
            sendManufacturerEnabled: boolValues[3],
            sendDeviceNameEnabled: boolValues[4],
            sendWifiNameEnabled: boolValues[5]
        )
    }

}
