import UIKit
import Combine
import Core
import Intents
import UI
import MediaPlayer
import WidgetKit
import AppIntents

public struct PlayWXYC: AudioStartingIntent {
    public static var title: LocalizedStringResource = "Play WXYC"
    
    public init() { }
    
    public func perform() async throws -> some IntentPerformResult {
        RadioPlayerController.shared.play()
        return .finished(value: "Now playing WXYC.")
    }
}

public struct WhatsPlayingOnWXYC: AppIntent {
    public static let title: LocalizedStringResource = "What’s Playing on WXYC?"
    public static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    
    public init() { }

    @MainActor
    public func perform() async throws -> some IntentPerformResult {
        guard let nowPlayingItem = await NowPlayingService.shared.fetch() else {
            return .finished(dialog: "An unknown song by an unknown artist is now playing on WXYC.")
        }
//        return .finished(value: _IntentValueType, view: <#T##View#>)
        return .finished(dialog: "\(nowPlayingItem.playcut.songTitle) by \(nowPlayingItem.playcut.artistName) is now playing on WXYC.")
    }

    public static var openAppWhenRun = false
}

public struct WXYCAppShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: WhatsPlayingOnWXYC(),
            phrases: ["What’s playing on WXYC?"]
        )
    }
}

@UIApplicationMain
@MainActor
class AppDelegate: UIResponder, UIApplicationDelegate {
    let cacheCoordinator = CacheCoordinator.WXYCPlaylist
    var nowPlayingObservation: Any?

    // MARK: UIApplicationDelegate
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = RootPageViewController()
        
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        // Make status bar white
        UINavigationBar.appearance().barStyle = .black

        Task {
#if os(iOS)
            await SiriService.shared.donateSiriIntentIfNeeded()
#endif
            
            self.nowPlayingObservation = NowPlayingService.shared.observe { nowPlayingItem in
                MPNowPlayingInfoCenter.default().update(nowPlayingItem: nowPlayingItem)
                WidgetCenter.shared.reloadAllTimelines()
                Task { await SiriService.shared.donate(nowPlayingItem: nowPlayingItem) }
            }
        }
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
#if os(iOS)
    func application(_ application: UIApplication, handle intent: INIntent) async -> INIntentResponse {
        return await SiriService.shared.handle(intent: intent)
    }
#endif
}
