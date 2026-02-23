//
//  PhotoTheme.swift
//  Wallpaper
//
//  Creates a synthetic LoadedTheme for photo backgrounds. Integrates with the existing
//  theme system by generating a ThemeManifest with renderer type `.photo`.
//
//  Created by Claude on 01/18/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Foundation

/// The unique identifier for the photo theme.
public let photoThemeID = "custom_photo"

/// Factory for creating the synthetic photo theme.
@MainActor
public enum PhotoThemeFactory {
    /// Creates a LoadedTheme for photo backgrounds.
    ///
    /// The theme uses the accent color from the photo metadata if available,
    /// otherwise falls back to sensible defaults.
    ///
    /// - Parameter storage: The photo storage to read metadata from.
    /// - Returns: A LoadedTheme for the photo background.
    public static func makeTheme(storage: PhotoBackgroundStorageProtocol) -> LoadedTheme {
        let accentColor: AccentColor
        if let metadata = storage.metadata {
            accentColor = metadata.accentColor
        } else {
            // Default accent color when no photo is set
            accentColor = AccentColor(hue: 210, saturation: 0.5, brightness: 1.0)
        }

        let manifest = ThemeManifest(
            id: photoThemeID,
            displayName: "Photo",
            version: "1.0.0",
            renderer: RendererConfiguration(type: .photo),
            parameters: [],
            shaderArguments: [],
            accent: accentColor,
            material: MaterialConfiguration(
                foreground: .light,
                blurRadius: 12.0,
                overlay: OverlayConfiguration(opacity: 0.2, darkness: 0.8)
            ),
            button: .colored
        )

        return LoadedTheme(manifest: manifest)
    }
}
