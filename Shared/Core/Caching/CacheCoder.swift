//
//  CacheCoder.swift
//  Core
//
//  Created by Jake Bromberg on 7/11/22.
//  Copyright © 2022 WXYC. All rights reserved.
//

import UIKit

protocol CacheCoder<Value> {
    associatedtype Value
    
    func encode(_ value: Value) throws -> Data
    func decode(_ data: Data) throws -> Value
}

struct JSONCacheCoder<Value: Codable>: CacheCoder {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func encode(_ value: Value) throws -> Data {
        return try encoder.encode(value)
    }
    
    func decode(_ data: Data) throws -> Value {
        return try decoder.decode(Value.self, from: data)
    }
}

struct ImageCacheCoder: CacheCoder {
    enum Error: Swift.Error {
        case encodingFailed
        case decodingFailed
    }
    
    func encode(_ value: UIImage) throws -> Data {
        guard let data = value.pngData() else {
            throw Error.encodingFailed
        }
        
        return data
    }
    
    func decode(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw Error.decodingFailed
        }
        
        return image
    }
}
