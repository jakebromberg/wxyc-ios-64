//
//  PhotoBackgroundStorage.swift
//  Wallpaper
//
//  Storage service for user-selected photo backgrounds. Stores images in the app group
//  container for widget access, with HEIF encoding for efficient storage.
//
//  Created by Claude on 01/18/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Caching
import Core
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Photo Background Metadata

/// Metadata stored alongside the photo background image.
public struct PhotoBackgroundMetadata: Codable, Sendable, Equatable {
    /// Extracted dominant color from the photo (HSB).
    public let accentHue: Double
    public let accentSaturation: Double
    public let accentBrightness: Double

    /// Timestamp when the photo was saved.
    public let savedAt: Date

    public init(
        accentHue: Double,
        accentSaturation: Double,
        accentBrightness: Double,
        savedAt: Date = Date()
    ) {
        self.accentHue = accentHue
        self.accentSaturation = accentSaturation
        self.accentBrightness = accentBrightness
        self.savedAt = savedAt
    }

    /// Returns the accent color as an AccentColor instance.
    public var accentColor: AccentColor {
        AccentColor(hue: accentHue, saturation: accentSaturation, brightness: accentBrightness)
    }
}

// MARK: - Photo Background Storage Protocol

/// Protocol for photo background storage, enabling dependency injection and testing.
@MainActor
public protocol PhotoBackgroundStorageProtocol: Sendable {
    /// Returns true if a photo background is currently saved.
    var hasPhoto: Bool { get }

    /// Returns the saved photo metadata, if available.
    var metadata: PhotoBackgroundMetadata? { get }

    /// Loads the saved photo image.
    func loadPhoto() async -> Core.Image?

    /// Saves a photo with the given image data.
    /// - Parameters:
    ///   - image: The image to save.
    ///   - maxDimension: Maximum dimension (width or height) to scale to. Defaults to 2x screen resolution.
    func savePhoto(_ image: Core.Image, maxDimension: CGFloat?) async throws

    /// Deletes the saved photo and metadata.
    func deletePhoto() throws
}

// MARK: - Photo Background Storage

/// Concrete implementation of photo background storage.
///
/// Stores images in the app group container (`group.wxyc.iphone/Library/Application Support/PhotoBackground/`)
/// for widget access. Uses HEIF encoding for efficient storage and scales images to max 2x screen resolution.
@MainActor
public final class PhotoBackgroundStorage: PhotoBackgroundStorageProtocol, @unchecked Sendable {
    // MARK: - Constants

    /// The subdirectory within the app group container.
    private static let subdirectory = "PhotoBackground"

    /// The filename for the stored photo.
    private static let photoFilename = "background.heic"

    /// UserDefaults key for metadata.
    private static let metadataKey = "wallpaper.photoBackground.metadata"

    // MARK: - Properties

    private let defaults: DefaultsStorage
    private let fileManager: FileManager

    /// Cached metadata loaded from UserDefaults.
    private var cachedMetadata: PhotoBackgroundMetadata?

    // MARK: - Initialization

    /// Creates a photo background storage instance.
    /// - Parameters:
    ///   - defaults: The defaults storage for metadata persistence.
    ///   - fileManager: The file manager for file operations.
    public init(
        defaults: DefaultsStorage = UserDefaults.wxyc,
        fileManager: FileManager = .default
    ) {
        self.defaults = defaults
        self.fileManager = fileManager
        self.cachedMetadata = loadMetadataFromDefaults()
    }

    // MARK: - PhotoBackgroundStorageProtocol

    public var hasPhoto: Bool {
        guard let url = photoURL else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    public var metadata: PhotoBackgroundMetadata? {
        cachedMetadata
    }

    public func loadPhoto() async -> Core.Image? {
        guard let url = photoURL else { return nil }
        guard let data = fileManager.contents(atPath: url.path) else { return nil }

        #if canImport(UIKit)
        return UIImage(data: data)
        #else
        return NSImage(data: data)
        #endif
    }

    public func savePhoto(_ image: Core.Image, maxDimension: CGFloat? = nil) async throws {
        // Determine max dimension (default to 2x screen resolution)
        #if canImport(UIKit)
        let screenScale = await UIScreen.main.scale
        let screenBounds = await UIScreen.main.bounds
        let defaultMax = max(screenBounds.width, screenBounds.height) * screenScale * 2
        #else
        let defaultMax: CGFloat = 2880 // Reasonable default for macOS
        #endif
        let targetMax = maxDimension ?? defaultMax

        // Scale image if needed
        let scaledImage = scaleImage(image, maxDimension: targetMax)

        // Encode as HEIF
        guard let data = encodeAsHEIF(scaledImage) else {
            throw PhotoBackgroundStorageError.encodingFailed
        }

        // Ensure directory exists
        try ensureDirectoryExists()

        // Write file
        guard let url = photoURL else {
            throw PhotoBackgroundStorageError.invalidPath
        }
        try data.write(to: url)

        // Extract accent color and save metadata
        let accentColor = extractDominantColor(from: scaledImage)
        let newMetadata = PhotoBackgroundMetadata(
            accentHue: accentColor.hue,
            accentSaturation: accentColor.saturation,
            accentBrightness: accentColor.brightness
        )
        saveMetadataToDefaults(newMetadata)
        cachedMetadata = newMetadata
    }

    public func deletePhoto() throws {
        // Delete file
        if let url = photoURL, fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }

        // Clear metadata
        defaults.removeObject(forKey: Self.metadataKey)
        cachedMetadata = nil
    }

    // MARK: - Private Helpers

    /// The URL for the photo file in the app group container.
    private var photoURL: URL? {
        guard let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.wxyc.iphone"
        ) else {
            return nil
        }
        return containerURL
            .appending(path: "Library/Application Support")
            .appending(path: Self.subdirectory)
            .appending(path: Self.photoFilename)
    }

    /// The directory URL for photo storage.
    private var directoryURL: URL? {
        guard let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.wxyc.iphone"
        ) else {
            return nil
        }
        return containerURL
            .appending(path: "Library/Application Support")
            .appending(path: Self.subdirectory)
    }

    /// Ensures the storage directory exists.
    private func ensureDirectoryExists() throws {
        guard let directoryURL else {
            throw PhotoBackgroundStorageError.invalidPath
        }
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    /// Scales an image to fit within the given maximum dimension while preserving aspect ratio.
    private func scaleImage(_ image: Core.Image, maxDimension: CGFloat) -> Core.Image {
        #if canImport(UIKit)
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        if scale >= 1.0 { return image }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        #else
        // macOS implementation
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        if scale >= 1.0 { return image }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: newSize),
                   from: CGRect(origin: .zero, size: size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
        #endif
    }

    /// Encodes an image as HEIF data.
    private func encodeAsHEIF(_ image: Core.Image) -> Data? {
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            "public.heic" as CFString,
            1,
            nil
        ) else {
            // Fall back to JPEG if HEIF isn't available
            return image.jpegData(compressionQuality: 0.85)
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            return image.jpegData(compressionQuality: 0.85)
        }
        return data as Data
        #else
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            "public.heic" as CFString,
            1,
            nil
        ) else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return data as Data
        #endif
    }

    /// Extracts the dominant color from an image using simple averaging.
    private func extractDominantColor(from image: Core.Image) -> AccentColor {
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else {
            return AccentColor(hue: 210, saturation: 0.5, brightness: 1.0)
        }

        // Sample a small resized version for performance
        let sampleSize = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: sampleSize)
        let sampledImage = renderer.image { context in
            context.cgContext.interpolationQuality = .low
            UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: sampleSize))
        }

        guard let sampledCGImage = sampledImage.cgImage,
              let dataProvider = sampledCGImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return AccentColor(hue: 210, saturation: 0.5, brightness: 1.0)
        }

        let bytesPerPixel = sampledCGImage.bitsPerPixel / 8
        let bytesPerRow = sampledCGImage.bytesPerRow
        let width = sampledCGImage.width
        let height = sampledCGImage.height

        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var count: CGFloat = 0

        for y in stride(from: 0, to: height, by: 2) {
            for x in stride(from: 0, to: width, by: 2) {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let r = CGFloat(bytes[offset]) / 255.0
                let g = CGFloat(bytes[offset + 1]) / 255.0
                let b = CGFloat(bytes[offset + 2]) / 255.0

                totalR += r
                totalG += g
                totalB += b
                count += 1
            }
        }

        guard count > 0 else {
            return AccentColor(hue: 210, saturation: 0.5, brightness: 1.0)
        }

        let avgR = totalR / count
        let avgG = totalG / count
        let avgB = totalB / count

        // Convert RGB to HSB
        let color = UIColor(red: avgR, green: avgG, blue: avgB, alpha: 1.0)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        return AccentColor(
            hue: hue * 360,
            saturation: max(0.3, saturation), // Ensure some saturation
            brightness: 1.0
        )
        #else
        // macOS fallback
        return AccentColor(hue: 210, saturation: 0.5, brightness: 1.0)
        #endif
    }

    /// Loads metadata from UserDefaults.
    private func loadMetadataFromDefaults() -> PhotoBackgroundMetadata? {
        guard let data = defaults.data(forKey: Self.metadataKey) else { return nil }
        return try? JSONDecoder().decode(PhotoBackgroundMetadata.self, from: data)
    }

    /// Saves metadata to UserDefaults.
    private func saveMetadataToDefaults(_ metadata: PhotoBackgroundMetadata) {
        guard let data = try? JSONEncoder().encode(metadata) else { return }
        defaults.set(data, forKey: Self.metadataKey)
    }
}

// MARK: - Errors

/// Errors that can occur during photo background storage operations.
public enum PhotoBackgroundStorageError: Error, LocalizedError {
    case encodingFailed
    case invalidPath

    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            "Failed to encode image"
        case .invalidPath:
            "Invalid storage path"
        }
    }
}
