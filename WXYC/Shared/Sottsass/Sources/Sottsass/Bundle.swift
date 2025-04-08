//
//  File.swift
//  Filler Art
//
//  Created by Jake Bromberg on 4/7/25.
//

import SwiftUI

extension Bundle {
    /// Returns a random background image from the Cassettes directory.
    static func randomBackground() -> Image? {
        guard let urls = Bundle.module.urls(forResourcesWithExtension: "png", subdirectory: "Cassettes"),
                let randomURL = urls.randomElement() else {
            print("❌ No background images found in Cassettes directory")
            return nil
        }
        let imageName = randomURL.deletingPathExtension().lastPathComponent
        print("🖼️ Loading background image: \(imageName) from URL: \(randomURL)")
        
        // Try loading the image directly from the URL
        if let imageData = try? Data(contentsOf: randomURL),
           let uiImage = UIImage(data: imageData) {
            print("✅ Successfully loaded background image")
            return Image(uiImage: uiImage)
        } else {
            print("❌ Failed to load background image data")
            return nil
        }
    }
    
    /// Returns a random sticker image from the Stickers directory.
    static func randomSticker() -> Image? {
        guard let urls = Bundle.module.urls(forResourcesWithExtension: "png", subdirectory: "Stickers"),
                let randomURL = urls.randomElement() else {
            print("❌ No sticker images found in Stickers directory")
            return nil
        }
        let imageName = randomURL.deletingPathExtension().lastPathComponent
        print("🎨 Loading sticker image: \(imageName) from URL: \(randomURL)")
        
        // Try loading the image directly from the URL
        if let imageData = try? Data(contentsOf: randomURL),
           let uiImage = UIImage(data: imageData) {
            print("✅ Successfully loaded sticker image")
            return Image(uiImage: uiImage)
        } else {
            print("❌ Failed to load sticker image data")
            return nil
        }
    }
    
    /// Returns a random font name from the Fonts directory.
    /// Assumes the font file name (without extension) is the PostScript name.
    static func randomFont() -> String? {
        guard let urls = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") else {
            print("❌ No font files found in Fonts directory")
            return nil
        }
        
        print("🔍 Found \(urls.count) font files in Fonts directory")
        
        var validFonts: [String] = []
        
        // Try each font and collect valid ones
        for url in urls {
            let fontName = url.deletingPathExtension().lastPathComponent
            print("\n🔄 Testing font: \(fontName)")
            
            guard let fontData = try? Data(contentsOf: url) else {
                print("❌ Failed to load font data")
                continue
            }
            
            print("✅ Successfully loaded font data")
            
            // Create font descriptors from the data
            guard let descriptors = CTFontManagerCreateFontDescriptorsFromData(fontData as CFData) as? [CTFontDescriptor] else {
                print("❌ Failed to create font descriptors from data")
                continue
            }
            
            var foundValidFont = false
            for descriptor in descriptors {
                // Get the PostScript name from the descriptor
                guard let postScriptName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String else {
                    continue
                }
                
                // Normalize both names for comparison
                let normalizedFontName = fontName.replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "_", with: "")
                let normalizedPostScriptName = postScriptName.replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "_", with: "")
                
                // Check if the font is valid
                guard normalizedPostScriptName == normalizedFontName || postScriptName == fontName else {
                    print("⚠️ Font name mismatch - Expected: \(fontName), Got: \(postScriptName)")
                    continue
                }
                
                print("✅ Found valid font: \(fontName)")
                print("ℹ️ Font PostScript name: \(postScriptName)")
                
                if let familyName = CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute) as? String {
                    print("ℹ️ Font family name: \(familyName)")
                }
                
                if let displayName = CTFontDescriptorCopyAttribute(descriptor, kCTFontDisplayNameAttribute) as? String {
                    print("ℹ️ Font display name: \(displayName)")
                }
                
                validFonts.append(fontName)
                foundValidFont = true
                break
            }
            
            if !foundValidFont {
                print("❌ No valid font descriptors found for \(fontName)")
            }
        }
        
        guard !validFonts.isEmpty else {
            print("❌ No valid fonts found")
            return nil
        }
        
        // Randomly select one of the valid fonts
        let selectedFont = validFonts.randomElement()!
        print("🎲 Randomly selected font: \(selectedFont)")
        return selectedFont
    }
}
