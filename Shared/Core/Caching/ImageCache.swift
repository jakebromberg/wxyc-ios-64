//
//  ImageStore.swift
//  WXYC
//
//  Created by Jake Bromberg on 2/26/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import Foundation

final class ImageCache: Cache {
    func set(data: Data?, for key: String) async {
        let path = self.tempDirectory + key
        guard FileManager.default.createFile(atPath: path, contents: data, attributes: nil) else {
            fatalError()
        }
    }
    
    func data(for key: String) async -> Data? {
        let path = self.tempDirectory + key
        
        return FileManager.default.contents(atPath: path)
    }
    
    private let tempDirectory = NSTemporaryDirectory()
}
