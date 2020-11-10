//
//  Bundle+RetargetlyDemo.swift
//  RetargetlyDemo
//
//  Created by José Valderrama on 27/06/2018.
//  Copyright © 2018 Retargetly. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
