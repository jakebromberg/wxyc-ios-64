//
//  CacheStore.swift
//  Core
//
//  Created by Jake Bromberg on 7/11/22.
//  Copyright © 2022 WXYC. All rights reserved.
//

import Foundation

protocol CacheStore: AnyObject {
    subscript(key: String) -> Data? { get set }
}

class FileCacheStore: CacheStore {
    let fileManager = FileManager.default
    
    subscript(key: String) -> Data? {
        get {
            let path = self.tempDirectory + key
            return fileManager.contents(atPath: path)
        }
        set {
            let path = self.tempDirectory + key
            guard fileManager.createFile(atPath: path, contents: newValue, attributes: nil) else {
                fatalError()
            }
        }
    }
    
    private let tempDirectory = NSTemporaryDirectory()
}

class UserDefaultsCacheStore: CacheStore {
    let defaults: UserDefaults
    
    init(defaults: UserDefaults = .WXYC) {
        self.defaults = defaults
    }
    
    subscript(key: String) -> Data? {
        get {
            defaults.data(forKey: key)
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    static let WXYC = UserDefaults(suiteName: "org.wxyc.apps")!
}
