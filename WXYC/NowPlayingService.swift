import Foundation
import UIKit.UIImage

struct NowPlayingViewModel {
    let primaryLabel: String
    let secondaryLabel: String
    let artwork: UIImage
    let mediaPlayerInfo: [String: Any]?
}

final class NowPlayingService {
    typealias Observation = (NowPlayingViewModel) -> ()

    private let observation: Observation
    private let station: RadioStation

    private let webservice = Webservice()


    private var artwork = UIImage(named: "albumArt")

    init(station: RadioStation, observation: @escaping Observation) {
        self.observation = observation

        _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.checkPlaylist), userInfo: nil, repeats: true)
    }

    @objc func checkPlaylist() {
        let playcutRequest = webservice.getCurrentPlaycut()
        playcutRequest.observe(with: self.update(with:))

        let imageRequest = playcutRequest.getArtwork()
        imageRequest.observe(with: self.handle(result:))
    }

    func update(with result: Result<Playcut>) {
        guard case let .success(playcut) = result else {
            return
        }

        let viewModel = NowPlayingViewModel(
            primaryLabel: playcut.artistName ?? station.desc,
            secondaryLabel: playcut.songTitle ?? station.name,
            artwork: self.artwork,
            mediaPlayerInfo: <#T##[String : Any]?#>
        )
        
        guard currentSongName != self.playcut.title else {
            return
        }

        DispatchQueue.main.async {
            if kDebugLog {
                print("METADATA artist: \(self.playcut.artist) | title: \(self.playcut.title) | album: \(self.playcut.album)")
            }

            // Update Labels
            self.artistLabel.text = self.playcut.artist
            self.songLabel.text = self.playcut.title
            self.updateUserActivityState(self.userActivity!)

            // songLabel animation
            self.songLabel.animation = "zoomIn"
            self.songLabel.duration = 1.5
            self.songLabel.damping = 1
            self.songLabel.animate()

            // Query API for album art
            self.updateLockScreen()
        }
    }

    func handle(result: Result<UIImage>) {
        if case let .success(image) = result {
            DispatchQueue.main.async { self.albumImageView.image = image }
        }
    }
}
