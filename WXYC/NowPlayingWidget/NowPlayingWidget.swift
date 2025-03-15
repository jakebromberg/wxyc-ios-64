//
//  NowPlayingWidget.swift
//  NowPlayingWidget
//
//  Created by Jake Bromberg on 1/13/22.
//  Copyright © 2022 WXYC. All rights reserved.
//

import WidgetKit
import SwiftUI
import Core
import PostHog
import AppIntents

final class Provider: TimelineProvider, Sendable {
    func placeholder(in context: Context) -> NowPlayingEntry {
        NowPlayingEntry.placeholder(family: context.family)
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (NowPlayingEntry) -> ()) {
        let family = context.family
        PostHogSDK.shared.capture(
            "nowplayingwidget getsnapshot",
            properties: ["family" : String(describing: family)]
        )
        
        if context.isPreview {
            completion(NowPlayingEntry.placeholder(family: family))
        } else {
            Task {
                // Fetch the now playing item.
                let nowPlayingItem = await NowPlayingService.shared.fetch() ?? .placeholder
                
                // Fetch playlist and get recent playcuts.
                let playlist = await PlaylistService.shared.fetchPlaylist()
                let playcuts = playlist.playcuts
                let recentPlaycuts = Array(playcuts.prefix(4)[1...])
                
                // Fetch artwork for the recent playcuts concurrently.
                let recentPlaycutsWithArtwork = await withTaskGroup(of: NowPlayingItem.self) { group -> [NowPlayingItem] in
                    var results = [NowPlayingItem]()
                    for playcut in recentPlaycuts {
                        group.addTask {
                            if let artwork = await ArtworkService.shared.getArtwork(for: playcut) {
                                return NowPlayingItem(playcut: playcut, artwork: artwork)
                            }
                            
                            return NowPlayingItem(playcut: playcut)
                        }
                    }
                    for await updated in group {
                        results.append(updated)
                    }
                    return results
                }
                
                let entry = NowPlayingEntry(
                    nowPlayingItem,
                    recentPlaycuts: recentPlaycutsWithArtwork,
                    family: family
                )
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> ()) {
        let family = context.family
        PostHogSDK.shared.capture(
            "nowplayingwidget gettimeline",
            properties: ["family" : String(describing: family)]
        )
        
        Task {
            // Fetch now playing item.
            let nowPlayingItem = await NowPlayingService.shared.fetch() ?? .placeholder
            
            // Fetch playlist and extract the first three playcuts.
            let playlist = await PlaylistService.shared.fetchPlaylist()
            let playcuts = playlist.playcuts
            let recentPlaycuts = Array(playcuts.prefix(4)[1...])
            
            // Fetch artwork for each of the recent playcuts concurrently.
            let recentPlaycutsWithArtwork = await withTaskGroup(of: NowPlayingItem.self) { group -> [NowPlayingItem] in
                var results = [NowPlayingItem]()
                for playcut in recentPlaycuts {
                    group.addTask {
                        if let artwork = await ArtworkService.shared.getArtwork(for: playcut) {
                            return NowPlayingItem(playcut: playcut, artwork: artwork)
                        }
                        
                        return NowPlayingItem(playcut: playcut)
                    }
                }
                for await updated in group {
                    results.append(updated)
                }
                return results
            }
            
            // Create the timeline entry including the now playing item and recent playcuts.
            let entry = NowPlayingEntry(
                nowPlayingItem,
                recentPlaycuts: recentPlaycutsWithArtwork,
                family: family
            )
            
            // Schedule the next update (for example, 5 minutes from now).
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

struct NowPlayingEntry: TimelineEntry {
    let date: Date = Date(timeIntervalSinceNow: 1)
    let artist: String
    let songTitle: String
    let artwork: Image?
    let recentPlaycuts: [NowPlayingItem]
    let family: WidgetFamily
    
    init(_ nowPlayingItem: NowPlayingItem, recentPlaycuts: [NowPlayingItem] = [], family: WidgetFamily) {
        self.artist = nowPlayingItem.playcut.artistName
        self.songTitle = nowPlayingItem.playcut.songTitle
        
        if let artwork = nowPlayingItem.artwork {
            self.artwork = Image(uiImage: artwork)
        } else {
            self.artwork = nil
        }
        
        self.recentPlaycuts = recentPlaycuts
        self.family = family
    }
    
    init(artist: String, songTitle: String, artwork: Image?, family: WidgetFamily) {
        self.artist = artist
        self.songTitle = songTitle
        self.artwork = artwork
        self.recentPlaycuts = []
        self.family = family
    }
    
    public static func placeholder(family: WidgetFamily) -> Self {
        NowPlayingEntry(
            artist: "WXYC 89.3 FM",
            songTitle: "Chapel Hill, NC",
            artwork: nil,
            family: family
        )
    }
}

protocol NowPlayingWidgetEntryView: View {
    associatedtype Artwork: View
    
    var entry: NowPlayingEntry { get }
    var artwork: Artwork { get }
}

extension NowPlayingWidgetEntryView {
    var artwork: some View {
        Group {
            if let artwork = entry.artwork {
                artwork
                    .resizable()
                    .frame(maxWidth: 800, maxHeight: 800)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .containerBackground(Color.clear, for: .widget)
            } else {
                Self.defaultArtwork
                    .frame(maxWidth: 800, maxHeight: 800)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .containerBackground(Color.clear, for: .widget)
            }
        }
    }
    
    private static var defaultArtwork: some View {
        ZStack {
            Rectangle()
                .opacity(0.2)
            Image("logo")
                .resizable()
                .scaleEffect(0.8)
        }
    }
    
    
}

struct SmallNowPlayingWidgetEntryView: NowPlayingWidgetEntryView {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(ImageResource(name: "background", bundle: .main))
                .resizable()
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            Color(white: 0, opacity: 0.25)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                self.artwork
                
                Text(entry.artist)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(entry.songTitle)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                PlayButton()
                    .background(Capsule().fill(Color.red))
                    .clipped()
                
            }
        }
        .safeAreaPadding()
    }
}

struct PlayButton: View {
    @AppStorage("isPlaying", store: .wxyc)
    var isPlaying: Bool = UserDefaults.wxyc.bool(forKey: "isPlaying")
    
    var body: some View {
        Button(intent: intent) {
            Image(systemName: resourceName)
                .foregroundStyle(.white)
                .font(.caption)
                .fontWeight(.bold)
                .invalidatableContent()
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .invalidatableContent()
        }
        .id(isPlaying)
    }
    
    var intent: any SystemIntent {
        ToggleWXYC()
    }
    
    var text: String {
        isPlaying ? "Pause" : "Play"
    }
    
    var resourceName: String {
        isPlaying ? "pause.fill" : "play.fill"
    }
}

struct MediumNowPlayingWidgetEntryView: NowPlayingWidgetEntryView {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(ImageResource(name: "background", bundle: .main))
                .resizable()
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            Color(white: 0, opacity: 0.25)
                .ignoresSafeArea()
            
            HStack(alignment: .center) {
                self.artwork
                    .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    
                    Text(entry.artist)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text(entry.songTitle)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    PlayButton()
                        .background(Capsule().fill(Color.red))
                        .clipped()
                    
                }
            }
        }
        .safeAreaPadding()
    }
}

struct Header: View {
    var entry: NowPlayingEntry
    
    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                Group {
                    Rectangle()
                        .aspectRatio(contentMode: .fit)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .clipped()
                        .frame(width: 100, height: 100, alignment: .leading)
                    
                    if let artwork = entry.artwork {
                        artwork
                            .resizable()
                            .cornerRadius(10)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100, maxHeight: 100)
                    } else {
                        Self.defaultArtwork
                            .cornerRadius(10)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 90, maxHeight: 90)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text(entry.artist)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(entry.songTitle)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                                
                PlayButton()
                    .background(Capsule().fill(Color.red))
                    .clipped()
                    .frame(alignment: .bottom)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private static var defaultArtwork: some View {
        ZStack {
            Rectangle()
                .opacity(0.2)
            Image("logo")
                .resizable()
                .scaleEffect(0.8)
        }
    }
}

struct RecentlyPlayedRow: View {
    let nowPlayingItem: NowPlayingItem
    let imageDimension = 45.0
    
    init(nowPlayingItem: NowPlayingItem) {
        self.nowPlayingItem = nowPlayingItem
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(uiImage: nowPlayingItem.artwork!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .clipped()
                .frame(
                    width: imageDimension,
                    height: imageDimension,
                    alignment: .leading
                )
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(nowPlayingItem.playcut.artistName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(nowPlayingItem.playcut.songTitle)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .clipped()
    }
}

struct LargeNowPlayingWidgetEntryView: NowPlayingWidgetEntryView {
    let entry: NowPlayingEntry
    
    init(entry: NowPlayingEntry) {
        self.entry = entry
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(ImageResource(name: "background", bundle: .main))
                .resizable()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .ignoresSafeArea()
            
            Color(white: 0, opacity: 0.25)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                
                Header(entry: entry)
                
//                Spacer()

                Text("Recently Played")
                    .font(.body.smallCaps().bold())
                    .foregroundStyle(.white)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                ForEach(entry.recentPlaycuts.sorted(by: \.playcut.chronOrderID)) { nowPlayingItem in
                    RecentlyPlayedRow(nowPlayingItem: nowPlayingItem)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
                Spacer()
            }
        }
        .safeAreaPadding()
        .containerBackground(Color.clear, for: .widget)
    }
    
    var rowCount: Int {
        print(">>>> \(PlaylistService.shared.playlist.playcuts.count)")
        print(">>>> \(PlaylistService.shared.playlist.playcuts)")
        return min(PlaylistService.shared.playlist.playcuts.count, 4)
    }
}

struct NowPlayingWidget: Widget {
    let kind: String = "NowPlayingWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry -> AnyView in
            switch entry.family {
            case .systemSmall:
                return AnyView(SmallNowPlayingWidgetEntryView(entry: entry))
            case .systemMedium:
                return AnyView(MediumNowPlayingWidgetEntryView(entry: entry))
            default:
                return AnyView(LargeNowPlayingWidgetEntryView(entry: entry))
            }
        }
        .contentMarginsDisabled()
    }
}

@main
struct NowPlayingWidgetBundle: WidgetBundle {
    var body: some Widget {
        NowPlayingControl()
        NowPlayingWidget()
    }
}

@available(iOSApplicationExtension 18.0, *)
struct NowPlayingControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(kind: "org.wxyc.control", intent: PlayWXYC.self) { config in
            ControlWidgetButton(action: config) {
                Image(systemName: "pause.fill")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
}

extension NowPlayingItem {
    static let placeholder = NowPlayingItem(
        playcut: Playcut(
            id: 0,
            hour: 0,
            chronOrderID: 0,
            songTitle: "Chapel Hill, NC",
            labelName: nil,
            artistName: "WXYC 89.3 FM",
            releaseTitle: nil
        ),
        artwork: UIImage(named: "")
    )
}

struct RemoteImage: View {
    let playcut: Playcut
    @State private var artwork: UIImage? = nil
    
    var body: some View {
        Group {
            if let artwork {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onAppear {
                        Task {
                            let artwork = await ArtworkService.shared.getArtwork(for: playcut)
                            assert(artwork != nil)
                            Task { @MainActor in
                                self.artwork = artwork
                                print(">>>> artwork updated")
                            }
                        }
                    }
            }
        }
    }
}

#Preview(as: .systemLarge) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(artist: "Autechre", songTitle: "VI Scose Poise", artwork: Image("logo"), family: .systemLarge)
}


extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { e1, e2 in
            e1[keyPath: keyPath] < e2[keyPath: keyPath]
        }
    }
}
