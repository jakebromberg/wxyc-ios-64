//
//  PlaylistCellViewModel.swift
//  WXYC
//
//  Created by Jake Bromberg on 3/19/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import UIKit
import Core

final class PlaylistCellViewModel {
  let viewClass: NSObject.Type
  let reuseIdentifier: String
  let configure: (UITableViewCell) -> ()
  let artworkService = ArtworkService.shared
  
  init<View: NSObject>(reuseIdentifier: String = NSStringFromClass(View.self), configure: @escaping (View) -> ()) {
    self.viewClass = View.self
    self.reuseIdentifier = reuseIdentifier
    
    self.configure = { cell in
      configure(cell as! View)
    }
  }
}
