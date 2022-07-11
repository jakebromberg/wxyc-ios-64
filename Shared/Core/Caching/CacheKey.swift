//
//  CacheKey.swift
//  WXYC
//
//  Created by Jake Bromberg on 2/26/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import Foundation
import UIKit

let DefaultLifespan: TimeInterval = 30

protocol CacheKey: Identifiable where ID == String {
    
}

extension Identifiable where ID: CustomStringConvertible {
    var cacheKey: some CacheKey { AnyCacheKey(id: id.description) }
}

struct AnyCacheKey: CacheKey {
    let id: String
}

extension Cache {
    func value(for key: any CacheKey) throws -> Value {
        try value(for: key.id)
    }
    
    func set(value: Value, for key: any CacheKey, lifespan: TimeInterval = DefaultLifespan) throws {
        try set(value: value, for: key.id, lifespan: lifespan)
    }
}
