//
//  PhotoBackgroundView.swift
//  Wallpaper
//
//  SwiftUI renderer for photo backgrounds. Loads the photo asynchronously from storage
//  and displays it with aspect-fill scaling.
//
//  Created by Claude on 01/18/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Core
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Environment Key

private struct PhotoBackgroundStorageKey: EnvironmentKey {
    static let defaultValue: PhotoBackgroundStorageProtocol? = nil
}

public extension EnvironmentValues {
    /// The photo background storage used by photo wallpaper renderers.
    var photoBackgroundStorage: PhotoBackgroundStorageProtocol? {
        get { self[PhotoBackgroundStorageKey.self] }
        set { self[PhotoBackgroundStorageKey.self] = newValue }
    }
}

/// SwiftUI view that renders a user-selected photo as a wallpaper background.
///
/// Loads the photo asynchronously from `PhotoBackgroundStorage` and displays it
/// with aspect-fill scaling. Works with the existing material blur overlay system.
public struct PhotoBackgroundView: View {
    /// The storage service for loading the photo.
    private let storage: PhotoBackgroundStorageProtocol

    /// Loaded image state.
    @State private var loadedImage: Core.Image?

    /// Whether the image is currently loading.
    @State private var isLoading = true

    /// Creates a photo background view.
    /// - Parameter storage: The storage service to load the photo from.
    public init(storage: PhotoBackgroundStorageProtocol) {
        self.storage = storage
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color while loading
                Color.black

                // Photo image with aspect-fill scaling
                if let image = loadedImage {
                    #if canImport(UIKit)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    #else
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    #endif
                } else if !isLoading {
                    // Fallback gradient when no photo is available
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await loadImage()
        }
    }

    /// Loads the image from storage.
    @MainActor
    private func loadImage() async {
        isLoading = true
        loadedImage = await storage.loadPhoto()
        isLoading = false
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Photo Background") {
    PhotoBackgroundView(storage: PreviewPhotoStorage())
}

/// Mock storage for previews that returns a system image.
@MainActor
private final class PreviewPhotoStorage: PhotoBackgroundStorageProtocol {
    var hasPhoto: Bool { true }
    var metadata: PhotoBackgroundMetadata? {
        PhotoBackgroundMetadata(
            accentHue: 210,
            accentSaturation: 0.7,
            accentBrightness: 1.0
        )
    }

    func loadPhoto() async -> Core.Image? {
        #if canImport(UIKit)
        UIImage(systemName: "photo.fill")
        #else
        nil
        #endif
    }

    func savePhoto(_ image: Core.Image, maxDimension: CGFloat?) async throws {}
    func deletePhoto() throws {}
}
#endif
