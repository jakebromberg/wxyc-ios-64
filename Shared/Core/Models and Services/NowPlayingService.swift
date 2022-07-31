//
//  PlaycutService.swift
//  WXYC
//
//  Created by Jake Bromberg on 12/3/17.
//  Copyright © 2017 wxyc.org. All rights reserved.
//

import Foundation
import UIKit
import Combine

public struct NowPlayingItem {
    public let playcut: Playcut
    public var artwork: UIImage?
}

public final class NowPlayingService: ObservableObject {
    public static let shared = NowPlayingService()
        
    @Published public var nowPlayingItem: NowPlayingItem? = nil
    
    public func fetch() async -> NowPlayingItem? {
        let playlist = await self.playlistService.fetchPlaylist(forceSync: true)
        guard let playcut = playlist.playcuts.first else {
            return nil
        }
        let artwork = await self.artworkService.getArtwork(for: playcut)
        return NowPlayingItem(playcut: playcut, artwork: artwork)
    }
    
    private var playcut: Playcut? = nil {
        didSet {
            guard oldValue?.id != self.playcut?.id, let playcut = self.playcut else {
                return
            }

            Task {
                let artwork = await self.artworkService.getArtwork(for: playcut)
                let nowPlayingItem = NowPlayingItem(playcut: playcut, artwork: artwork)
                self.nowPlayingItem = nowPlayingItem
                self.nowPlayingObservable.send(nowPlayingItem)
            }
        }
    }
    
    private let playlistService: PlaylistService
    private let artworkService: ArtworkService
    
    private var playcutObservation: Cancellable? = nil
    private let nowPlayingObservable = PassthroughSubject<NowPlayingItem, Never>()

    internal init(
        playlistService: PlaylistService = .shared,
        artworkService: ArtworkService = .shared
    ) {
        self.playlistService = playlistService
        self.artworkService = artworkService
        
        self.playcutObservation = self.playlistService
            .$playlist
            .compactMap(\.playcuts.first)
            .map(Optional.init)
            .receive(on: RunLoop.main)
            .assign(to: \.playcut, on: self)
    }
}
