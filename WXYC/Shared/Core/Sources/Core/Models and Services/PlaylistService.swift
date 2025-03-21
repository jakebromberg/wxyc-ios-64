//
//  PlaylistService.swift
//  WXYC
//
//  Created by Jake Bromberg on 12/15/18.
//  Copyright © 2018 WXYC. All rights reserved.
//

import Foundation
import Logger
import PostHog
import SwiftUI

protocol PlaylistFetcher: Sendable {
    func getPlaylist() async throws -> Playlist
}

extension CacheCoordinator: PlaylistFetcher {
    static let playlistKey = "playlist"
    
    func getPlaylist() async throws -> Playlist {
        try await self.value(for: CacheCoordinator.playlistKey)
    }
}

extension URLSession: PlaylistFetcher {
    func getPlaylist() async throws -> Playlist {
        let (playlistData, _) = try await self.data(from: URL.WXYCPlaylist)
        let decoder = JSONDecoder()
        return try decoder.decode(Playlist.self, from: playlistData)
    }
}

public final class PlaylistService: Sendable {
    public static let shared = PlaylistService()
    
    @MainActor
    public private(set) var playlist: Playlist = .empty {
        didSet {
            for o in observers {
                o(self.playlist)
            }
        }
    }
        
    public typealias Observer = @MainActor @Sendable (Playlist) -> ()
    @MainActor private var observers: [Observer] = []
    
    @MainActor
    public func observe(_ observer: @escaping Observer) {
        Task { @MainActor in
            observer(self.playlist)
            self.observers.append(observer)
        }
    }
    
    init(
        cacheCoordinator: CacheCoordinator = .WXYCPlaylist,
        cachedFetcher: PlaylistFetcher = CacheCoordinator.WXYCPlaylist,
        remoteFetcher: PlaylistFetcher = URLSession.shared
    ) {
        self.cacheCoordinator = cacheCoordinator
        self.cachedFetcher = cachedFetcher
        self.remoteFetcher = remoteFetcher
        
        self.fetchTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global(qos: .default)) as? DispatchSource
        self.fetchTimer?.schedule(deadline: .now(), repeating: Self.defaultFetchInterval)
        self.fetchTimer?.setEventHandler {
            Task { @PlaylistActor in
                let playlist = await self.fetchPlaylist()
                
                if playlist.entries.isEmpty {
                    Log(.info, "Empty playlist")
                }
                
                guard await playlist != self.playlist else {
                    Log(.info,
                        """
                        No change in playlist: 
                        old count \(await self.playlist.entries.count)
                        new count \(playlist.entries.count)
                        """
                    )
                    
                    return
                }
                
                Log(.info, "fetched playlist with ids \(playlist.entries.map(\.id))")
                
                self.set(playlist: playlist)
                await self.cacheCoordinator.set(
                    value: self.playlist,
                    for: CacheCoordinator.playlistKey,
                    lifespan: DefaultLifespan
                )
            }
        }
        self.fetchTimer?.resume()
    }
    
    deinit {
        self.fetchTimer?.cancel()
    }
    
    public func fetchPlaylist(forceSync: Bool = false) async -> Playlist {
        Log(.info, "Fetching remote playlist")
        let startTime = Date.timeIntervalSinceReferenceDate
        do {
            let playlist = try await self.remoteFetcher.getPlaylist()
            let duration = Date.timeIntervalSinceReferenceDate - startTime
            Log(.info, "Remote playlist fetch succeeded: fetch time \(duration), entry count \(playlist.entries.count)")
            return playlist
        } catch {
            let duration = Date.timeIntervalSinceReferenceDate - startTime
            Log(.error, "Remote playlist fetch failed after \(duration) seconds: \(error)")
            PostHogSDK.shared.capture(error: error, context: "fetchPlaylist")
            
            return Playlist.empty
        }
    }
    
    // MARK: Private
    
    private static let defaultFetchInterval: TimeInterval = 30
    
    private let cacheCoordinator: CacheCoordinator
    private let cachedFetcher: PlaylistFetcher
    private let remoteFetcher: PlaylistFetcher
    private let fetchTimer: DispatchSource?
    
    private func set(playlist: Playlist) {
        Task { @MainActor in self.playlist = playlist }
    }
    
    @globalActor
    public actor PlaylistActor: GlobalActor, Sendable {
        public static let shared = PlaylistActor()
    }
}
