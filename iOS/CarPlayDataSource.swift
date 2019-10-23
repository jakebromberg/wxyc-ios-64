//
//  CarPlayDataSource.swift
//  WXYC
//
//  Created by Jake Bromberg on 9/18/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import Foundation
import MediaPlayer
import Core

enum CarPlayDataSourceErrors: Error {
    case noPlaycut
}

class CarPlayDataSource: NSObject, MPPlayableContentDataSource {
    var playcutResult: Result<Playcut> = .error(CarPlayDataSourceErrors.noPlaycut)
    var artworkResult: Result<UIImage> = .error(CarPlayDataSourceErrors.noPlaycut)
    var viewModels: [PlaylistCellViewModel] = []

    
    override init() {
        //    PlaylistDataSource.shared.add(observer: <#T##PlaylistPresentable#>)
    }
    
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        return self.viewModels.count
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        return nil
    }
}

private extension MPContentItem {
    convenience init(_ viewModel: PlaylistCellViewModel) {
        self.init()
        
//        self.title = viewModel.
    }
}

extension CarPlayDataSource: PlaylistPresentable {
    func updateWith(viewModels: [PlaylistCellViewModel]) {
        self.viewModels = viewModels
    }
}

extension CarPlayDataSource: NowPlayingServiceObserver {
    func updateWith(playcutResult: Result<Playcut>) {
        self.playcutResult = playcutResult
    }
    
    func updateWith(artworkResult: Result<UIImage>) {
        self.artworkResult = artworkResult
    }
}

class CarPlayDelegate: NSObject, MPPlayableContentDelegate {
    
}
