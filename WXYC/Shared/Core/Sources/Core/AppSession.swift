//
//  AppSession.swift
//  WatchXYC App
//
//  Created by Jake Bromberg on 2/28/25.
//  Copyright © 2025 WXYC. All rights reserved.
//

import Foundation
import Logger

public let SessionStartTime = Date.now.timeIntervalSince1970

@discardableResult
public func validateCollection(_ collection: any Collection, label: String) -> Bool {
    if collection.isEmpty {
        Log(.info, "\(label) is empty. Session duration: \(Date.now.timeIntervalSince1970 - SessionStartTime)")
        return false
    }
    
    return true
}
