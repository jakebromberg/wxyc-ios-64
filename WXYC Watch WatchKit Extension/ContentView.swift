//
//  ContentView.swift
//  WXYC Watch WatchKit Extension
//
//  Created by Jake Bromberg on 9/12/19.
//  Copyright © 2019 WXYC. All rights reserved.
//

import SwiftUI
import Core

struct ContentView: View, NowPlayingServiceObserver {
  func updateWith(playcutResult: Result<Playcut>) {
    
  }
  
  func updateWith(artworkResult: Result<UIImage>) {
    
  }

    var body: some View {
        Text("Hello World")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
