//
//  PlaylistCacheKeys.swift
//  WXYC
//
//  Created by Jake Bromberg on 2/26/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import Foundation

enum PlaylistCacheKeys: String, CacheKey {
    case playlist
    
    var id: String { rawValue }
}
