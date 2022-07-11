//
//  PlaylistService.swift
//  WXYC
//
//  Created by Jake Bromberg on 12/15/18.
//  Copyright © 2018 WXYC. All rights reserved.
//

import Foundation
import Combine

protocol PlaylistFetcher {
    func fetchPlaylist() async throws -> Playlist
}

extension Cache: PlaylistFetcher where Value == Playlist {
    func fetchPlaylist() async throws -> Playlist {
        try self.value(for: PlaylistCacheKeys.playlist)
    }
}

extension URLSession: PlaylistFetcher {
    static let decoder = JSONDecoder()
    
    func fetchPlaylist() async throws -> Playlist {
        let (playlistData, _) = try await self.data(from: URL.WXYCPlaylist)
        return try Self.decoder.decode(Playlist.self, from: playlistData)
    }
}

public class PlaylistService {
    public static let shared = PlaylistService()
    
    @Published public private(set) var playlist: Playlist = .empty
    
    private var cache: Cache<Playlist>
    private var remoteFetcher: PlaylistFetcher
    private var fetchTimer: DispatchSourceTimer? = nil
    
    private init(
        cache: Cache<Playlist> = PlaylistCache,
        remoteFetcher: PlaylistFetcher = URLSession.shared
    ) {
        self.cache = cache
        self.remoteFetcher = remoteFetcher
        
        self.fetchTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global(qos: .default))
        self.fetchTimer?.schedule(deadline: .now(), repeating: 30)
        self.fetchTimer?.setEventHandler {
            Task {
                let playlist = await self.fetchPlaylist()
                
                guard playlist != self.playlist else {
                    return
                }
                
                self.playlist = playlist
                try self.cache.set(
                    value: self.playlist,
                    for: PlaylistCacheKeys.playlist.rawValue
                )
            }
        }
        self.fetchTimer?.resume()
    }
    
    deinit {
        self.fetchTimer?.cancel()
    }
    
    public func fetchPlaylist(forceSync: Bool = false) async -> Playlist {
        print(">>> fetching playlist async")

        if !forceSync {
            do {
                return try await self.cache.fetchPlaylist()
            } catch {
                print(">>> No cached playlist")
            }
        }
        
        do {
            return try await self.remoteFetcher.fetchPlaylist()
        } catch {
            print(">>> Remote playlist fetch failed: \(error)")
        }
        
        return Playlist.empty
    }
}
