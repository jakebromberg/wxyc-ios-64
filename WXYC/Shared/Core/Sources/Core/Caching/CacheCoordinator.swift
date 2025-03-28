import Foundation
import UIKit
import Logger
import PostHog
import Analytics

let DefaultLifespan: TimeInterval = 30

public final actor CacheCoordinator {
    public static let Widgets = CacheCoordinator(cache: UserDefaultsCache())
    public static let WXYCPlaylist = CacheCoordinator(cache: UserDefaultsCache())
    public static let AlbumArt = CacheCoordinator(cache: DiskCache())
    
    internal init(cache: Cache) {
        self.cache = cache
        self.purgeRecords()
    }
    
    // MARK: Private vars
    
    private var cache: Cache
    
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    // MARK: Public methods
    
    public func value<Value, Key>(for key: Key) async throws -> Value
        where Value: Codable, Key: RawRepresentable, Key.RawValue == String
    {
        try await self.value(for: key.rawValue)
    }
    
    public func value<Value, Key>(for key: Key) async throws -> Value
        where Value: Codable, Key: Identifiable, Key.ID: LosslessStringConvertible
    {
        try await self.value(for: String(key.id))
    }
    
    public func value<Value: Codable>(for key: String) async throws -> Value {
        do {
            guard let encodedCachedRecord = self.cache.object(for: key) else {
                throw ServiceError.noCachedResult
            }
            
            let cachedRecord = try self.decode(CachedRecord<Value>.self, encodedCachedRecord)
            
            // nil out record, if expired
            guard !cachedRecord.isExpired else {
                self.cache.set(object: nil, for: key) // Nil-out expired record
                
                throw ServiceError.noCachedResult
            }
            
            Log(.info, "cache hit!", key, cachedRecord.value)
            
            return cachedRecord.value
        } catch {
            Log(.error, "No value for '\(key)': ", error)
            throw error
        }
    }
    
    public func set<Value, Key>(value: Value?, for key: Key, lifespan: TimeInterval)
        where Value: Codable, Key: RawRepresentable, Key.RawValue == String
    {
        self.set(value: value, for: key.rawValue, lifespan: lifespan)
    }
    
    public func set<Value, Key>(value: Value?, for key: Key, lifespan: TimeInterval)
        where Value: Codable, Key: Identifiable, Key.ID: LosslessStringConvertible
    {
        self.set(value: value, for: String(key.id), lifespan: lifespan)
    }
    
    public func set<Value: Codable>(value: Value?, for key: String, lifespan: TimeInterval) {
        Log(.info, "Setting value for key \(key). Value is \(value == nil ? "nil" : "not nil"). Lifespan: \(lifespan)")
        
        if let value {
            let cachedRecord = CachedRecord(value: value, lifespan: lifespan)
            do {
                let encodedCachedRecord = try Self.encoder.encode(cachedRecord)
                self.cache.set(object: encodedCachedRecord, for: key)
            } catch {
                Log(.error, "Failed to encode value for \(key): \(error)")
                PostHogSDK.shared.capture(error: error, context: "CacheCoordinator encode value")
            }
        } else {
            self.cache.set(object: nil, for: key)
        }
    }
    
    // MARK: Private methods
    
    private nonisolated func decode<T>(_ type: T.Type, _ value: Data) throws -> T where T: Decodable {
        do {
            return try Self.decoder.decode(T.self, from: value)
        } catch {
            Log(.error, "CacheCoordinator failed to decode value: \(error)")
            
            if T.self != CachedRecord<ArtworkService.Error>.self {
                PostHogSDK.shared.capture(error: error, context: "CacheCoordinator decode value")
            }
            
            throw error
        }
    }
    
    private nonisolated func purgeRecords() {
        Task {
            Log(.info, "Purging records")
            let cache = await self.cache
            for (key, value) in cache.allRecords() {
                do {
                    let record = try self.decode(CachedRecord<Data>.self, value)
                    if record.isExpired || record.lifespan == .distantFuture {
                        cache.set(object: nil, for: key)
                    }
                } catch {
                    PostHogSDK.shared.capture(
                        error: error,
                        context: "CacheCoordinator decode value",
                        additionalData: ["key" : key]
                    )
                    Log(.error, "Failed to decode value for \(key): \(error)\nDeleting it anyway.")
                    cache.set(object: nil, for: key)
                }
            }
        }
    }
}

#if DEBUG
extension FileManager {
    func nukeFileSystem() {
        if let cachesURL = urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let subdirectories = try contentsOfDirectory(at: cachesURL, includingPropertiesForKeys: nil)
                
                for subdirectory in subdirectories {
                    var isDirectory: ObjCBool = false
                    if fileExists(atPath: subdirectory.path, isDirectory: &isDirectory), isDirectory.boolValue {
                        try removeItem(at: subdirectory)
                        Log(.info, "Deleted subdirectory: \(subdirectory.lastPathComponent)")
                    }
                }
            } catch {
                Log(.error, "Error clearing subdirectories: \(error)")
            }
        }
    }
    

    func listFilesRecursively(at url: URL) {
        do {
            let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey]
            let directoryContents = try contentsOfDirectory(at: url, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles])

            for item in directoryContents {
                let resourceValues = try item.resourceValues(forKeys: Set(resourceKeys))

                if resourceValues.isDirectory == true {
                    Log(.info, "📂 Directory: \(item.lastPathComponent)")
                    listFilesRecursively(at: item)  // Recursive call for subdirectories
                } else {
                    let fileSize = resourceValues.fileSize ?? 0
                    Log(.info, "📄 File: \(item.lastPathComponent) - \(fileSize) bytes")
                }
            }
        } catch {
            Log(.error, "Error listing directory contents: \(error)")
        }
        
        let directories: [SearchPathDirectory] = [
            .applicationDirectory,
            .demoApplicationDirectory,
            .developerApplicationDirectory,
            .adminApplicationDirectory,
            .libraryDirectory,
            .developerDirectory,
            .userDirectory,
            .documentationDirectory,
            .documentDirectory,
            .coreServiceDirectory,
            .autosavedInformationDirectory,
            .desktopDirectory,
            .cachesDirectory,
            .applicationSupportDirectory,
            .downloadsDirectory,
            .inputMethodsDirectory,
            .moviesDirectory,
            .musicDirectory,
            .picturesDirectory,
            .printerDescriptionDirectory,
            .sharedPublicDirectory,
            .preferencePanesDirectory,
            .itemReplacementDirectory,
            .allApplicationsDirectory,
            .allLibrariesDirectory,
        ]
        
        for d in directories {
            if let documentsURL = FileManager.default.urls(for: d, in: .userDomainMask).first {
                Log(.info, "Listing contents of: \(documentsURL.path)")
                listFilesRecursively(at: documentsURL)
            }
        }
    }
}
#endif
