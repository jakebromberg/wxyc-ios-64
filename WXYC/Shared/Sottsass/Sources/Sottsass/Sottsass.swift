import SwiftUI

public struct Sottsass: View {
  // MARK: - Static Constants
  static let textPlacement: CGPoint = CGPoint(x: 100, y: 200)

  // MARK: - Randomly Chosen Assets & Parameters (Internal)
  private let backgroundImage: Image
  private let stickerImage: Image
  private let font: Font
  private let rotationAngle: Double
  private let stickerBounds: Path

  // MARK: - External Properties
  var text: String
  var scaleFactor: CGFloat

  // MARK: - Initialization
  public init(text: String, scaleFactor: CGFloat) {
    self.text = text
    self.scaleFactor = scaleFactor

    // Randomly choose a background image from the Media directory
    if let background = Bundle.randomBackground() {
      self.backgroundImage = background
    } else {
      print("⚠️ No background images found in Media directory")
      self.backgroundImage = Image(systemName: "photo")
    }

    // Randomly choose a sticker image from the Stickers directory
    if let sticker = Bundle.randomSticker() {
      self.stickerImage = sticker
    } else {
      print("⚠️ No sticker images found in Stickers directory")
      self.stickerImage = Image(systemName: "star")
    }

    // Randomly choose a custom font from the Fonts directory
    if let randomFontName = Bundle.randomFont() {
      self.font = Font.custom(randomFontName, size: 24)
    } else {
      print("⚠️ No fonts found in Fonts directory")
      self.font = .system(size: 24, weight: .bold)
    }

    // Random rotation angle between 0 and 15 degrees
    self.rotationAngle = Double.random(in: 0...15)

    // Define sticker bounds as a circular path at a random location
    let randomX = CGFloat.random(in: 150...250)
    let randomY = CGFloat.random(in: 300...400)
    self.stickerBounds = Path { path in
      path.addEllipse(in: CGRect(x: randomX, y: randomY, width: 100, height: 100))
    }
  }

  // MARK: - Body
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Background image.
        backgroundImage
          .resizable()
          .renderingMode(.original)
          .aspectRatio(contentMode: .fit)
          .frame(width: geometry.size.width, height: geometry.size.height)
          .clipped()
          .onAppear {
            print("📱 Background image size: \(geometry.size)")
          }

        // Text overlay.
        Text(text)
          .font(font)
          .foregroundColor(.black)
          .position(Sottsass.textPlacement)

        // Sticker image with transformations.
        //                stickerImage
        //                    .resizable()
        //                    .renderingMode(.original)
        //                    .scaledToFit()
        //                    .frame(width: 100, height: 100)
        //                    .rotationEffect(.degrees(rotationAngle))
        //                    .scaleEffect(scaleFactor)
        //                    .position(stickerCenter())
        //                    .clipped()
        //                    .onAppear {
        //                        print("🎨 Sticker position: \(stickerCenter())")
        //                    }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.gray.opacity(0.1))  // Debug background
    }
  }

  // Helper: Compute the center of the sticker based on the bounds of the Path.
  private func stickerCenter() -> CGPoint {
    let rect = stickerBounds.cgPath.boundingBox
    return CGPoint(x: rect.midX, y: rect.midY)
  }
}

struct SottsassDescriptor {
  let media: Image
  let text: String
  let textPlacement: CGPoint
  let stickerName: Image
  let stickerBounds: Path
  let rotationAngle: Double
  let scaleFactor: CGFloat
}

#Preview {
  Sottsass(text: "Hello", scaleFactor: 1.0)
}
