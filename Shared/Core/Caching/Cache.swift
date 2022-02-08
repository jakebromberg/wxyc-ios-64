//
//  Defaults.swift
//  WXYC
//
//  Created by Jake Bromberg on 2/26/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import Foundation

protocol Cache {
    func set(data: Data?, for key: String) async
    func data(for key: String) async -> Data?
}

extension UserDefaults {
    static let WXYC = UserDefaults(suiteName: "org.wxyc.apps")!
}

extension UserDefaults: Cache {
    func set(data: Data?, for key: String) async {
        self.set(data, forKey: key)
    }
    
    func data(for key: String) async -> Data? {
        self.object(forKey: key) as? Data
    }
}
