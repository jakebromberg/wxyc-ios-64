//
//  Cache.swift
//  Core
//
//  Created by Jake Bromberg on 7/11/22.
//  Copyright © 2022 WXYC. All rights reserved.
//

import Foundation

let ArtworkCache = Cache(coder: ImageCacheCoder(), store: FileCacheStore())
public let PlaylistCache = Cache(coder: JSONCacheCoder<Playlist>(), store: UserDefaultsCacheStore())

public class Cache<Value> {
    enum Error: Swift.Error {
        case cacheMiss
        case cacheValueExpired
    }
    
    typealias Coder = any CacheCoder<Value>
    
    private let coder: Coder
    private let store: CacheStore
    private let cacheRecordCoder = JSONCacheCoder<CacheRecord<Data>>()
    
    init(coder: Coder, store: CacheStore) {
        self.coder = coder
        self.store = store
    }
    
    func value(for key: String) throws -> Value {
        guard let data = store[key] else {
            throw Error.cacheMiss
        }
        
        let record = try cacheRecordCoder.decode(data)
        
        if record.isExpired {
            throw Error.cacheValueExpired
        }
        
        return try coder.decode(data)
    }
    
    func set(value: Value?, for key: String, lifespan: TimeInterval = DefaultLifespan) throws {
        if let value = value {
            let data = try coder.encode(value)
            let record = CacheRecord(value: data, lifespan: lifespan)
            self.store[key] = try cacheRecordCoder.encode(record)
        } else {
            self.store[key] = nil
        }
    }
}
