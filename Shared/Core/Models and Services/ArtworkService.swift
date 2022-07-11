//
//  ArtworkService.swift
//  Core
//
//  Created by Jake Bromberg on 12/5/18.
//  Copyright © 2018 WXYC. All rights reserved.
//

import Foundation
import UIKit
import Combine

public final actor ArtworkService {
    public static let shared = ArtworkService(fetchers: [
        ArtworkCache,
        RemoteArtworkFetcher(configuration: .discogs),
        RemoteArtworkFetcher(configuration: .lastFM),
        RemoteArtworkFetcher(configuration: .iTunes),
    ])

    private let fetchers: [ArtworkFetcher]

    private init(fetchers: [ArtworkFetcher]) {
        self.fetchers = fetchers
    }

    public func getArtwork(for playcut: Playcut) async -> UIImage? {
        for fetcher in self.fetchers {
            do {
                return try await fetcher.fetchArtwork(for: playcut)
            } catch {
                print(">>> No artwork found for \(playcut) using fetcher \(fetcher)")
            }
        }
        
        return nil
    }
}

protocol ArtworkFetcher {
    func fetchArtwork(for playcut: Playcut) async throws -> UIImage
}

extension Cache: ArtworkFetcher where Value == UIImage {
    func fetchArtwork(for playcut: Playcut) async throws -> UIImage {
        guard let artwork: UIImage = try? self.value(for: playcut.cacheKey) else {
            throw ServiceErrors.noCachedResult
        }
        
        return artwork
    }
}

internal final class RemoteArtworkFetcher: ArtworkFetcher {
    internal struct Configuration {
        let makeSearchURL: (Playcut) -> URL
        let extractURL: (Data) throws -> URL
    }
    
    private let session: WebSession
    private let cache: Cache<UIImage>
    private let configuration: Configuration
    
    private var cacheOperation: Cancellable?
    
    internal init(
        configuration: Configuration,
        cache: Cache<UIImage> = ArtworkCache,
        session: WebSession = URLSession.shared
    ) {
        self.configuration = configuration
        self.cache = cache
        self.session = session
    }
    
    internal func fetchArtwork(for playcut: Playcut) async throws -> UIImage {
        let artworkURL = try await self.findArtworkURL(for: playcut)
        let artwork = try await self.downloadArtwork(at: artworkURL)

        try self.cache.set(value: artwork, for: playcut.cacheKey, lifespan: .distantFuture)
        
        return artwork
    }
    
    private func findArtworkURL(for playcut: Playcut) async throws -> URL {
        let searchURLRequest = self.configuration.makeSearchURL(playcut)
        let (data, _) = try await URLSession.shared.data(from: searchURLRequest)
        return try self.configuration.extractURL(data)
    }
    
    private func downloadArtwork(at url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw ServiceErrors.noResults
        }
        
        return image
    }
}
