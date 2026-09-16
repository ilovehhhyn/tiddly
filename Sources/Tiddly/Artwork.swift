import AppKit
import TiddlyCore

enum Pose: String { case idle, sleepy, wine1, wine2, wine3, water1, water2 }
enum DrinkKind { case wine, water }

/// Helen's PNG sheets are the canonical artwork. Every crop below selects an existing drawing; nothing is redrawn.
enum Artwork {
  static let resources: URL = {
    if let url = Bundle.main.resourceURL, FileManager.default.fileExists(atPath: url.appendingPathComponent("source").path) { return url }
    return URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().appendingPathComponent("../../../assets").standardizedFileURL
  }()
  private(set) static var regularFontName: String?
  private(set) static var boldFontName: String?
  private static var sheets: [String: CGImage] = [:]
  private static var crops: [String: NSImage] = [:]

  static func registerFonts() {
    regularFontName = registerFont("Gaegu-Regular.ttf")
    boldFontName = registerFont("Gaegu-Bold.ttf")
  }

  private static func registerFont(_ file: String) -> String? {
    let url = resources.appendingPathComponent("fonts").appendingPathComponent(file)
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor], let first = descriptors.first else { return nil }
    return CTFontDescriptorCopyAttribute(first, kCTFontNameAttribute) as? String
  }

  /// `element` is the CSS box size, `sheet` the CSS background-size, and `x`/`y` the negated background-position.
  static func crop(_ file: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, sheet: CGFloat) -> NSImage? {
    let key = "\(file)|\(x)|\(y)|\(width)|\(height)|\(sheet)"
    if let cached = crops[key] { return cached }
    guard let image = sheetImage(file) else { return nil }
    let scale = CGFloat(image.width) / sheet
    let source = CGRect(x: x * scale, y: y * scale, width: width * scale, height: height * scale)
    guard let cropped = image.cropping(to: source) else { return nil }
    let result = NSImage(cgImage: cropped, size: NSSize(width: width, height: height))
    crops[key] = result
    return result
  }

  private static func sheetImage(_ file: String) -> CGImage? {
    if let cached = sheets[file] { return cached }
    let url = resources.appendingPathComponent("source").appendingPathComponent(file)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
      NSLog("Tiddly: missing artwork %@", url.path); return nil
    }
    sheets[file] = image
    return image
  }

  static let spriteSize: CGFloat = 152

  static func sprite(_ character: PetCharacter, _ pose: Pose) -> NSImage? {
    let (file, point): (String, CGPoint) = {
      switch (character, pose) {
      case (.hedgehog, .wine1): return ("hedgehog-v2-original.png", CGPoint(x: 141, y: 136))
      case (.hedgehog, .water1): return ("hedgehog-v2-original.png", CGPoint(x: 333, y: 142))
      case (.hedgehog, .water2): return ("hedgehog-v2-original.png", CGPoint(x: 309, y: 286))
      case (.hedgehog, _): return ("hedgehog-v2-original.png", CGPoint(x: 83, y: 278))
      case (.owl, .sleepy): return ("owl-v2-original.png", CGPoint(x: 307, y: 16))
      case (.owl, .water1): return ("owl-v2-original.png", CGPoint(x: 432, y: 189))
      case (.owl, .wine1): return ("owl-v2-original.png", CGPoint(x: 48, y: 63))
      case (.owl, .wine2): return ("owl-v2-original.png", CGPoint(x: 40, y: 398))
      case (.owl, .wine3): return ("owl-v2-original.png", CGPoint(x: 382, y: 385))
      case (.owl, _): return ("owl-v2-original.png", CGPoint(x: 187, y: 181))
      }
    }()
    return crop(file, x: point.x, y: point.y, width: spriteSize, height: spriteSize, sheet: 630)
  }

  static func poses(_ character: PetCharacter, _ kind: DrinkKind) -> [Pose] {
    switch (character, kind) {
    case (.hedgehog, .wine): return [.wine1]
    case (.hedgehog, .water): return [.water1, .water2]
    case (.owl, .wine): return [.wine1, .wine2, .wine3]
    case (.owl, .water): return [.water1]
    }
  }

  struct DrinkStep { let width: CGFloat; let height: CGFloat; let image: NSImage? }

  static func drinkStep(_ kind: DrinkKind, _ step: Int) -> DrinkStep {
    let spec: (w: CGFloat, h: CGFloat, sheet: CGFloat, x: CGFloat, y: CGFloat) = {
      switch (kind, step) {
      case (.wine, 1): return (69, 113, 1126, 133, 499)
      case (.wine, 2): return (94, 222, 922, 311, 288)
      case (.wine, 3): return (122, 223, 901, 418, 272)
      case (.wine, _): return (181, 228, 860, 612, 248)
      case (.water, 1): return (80, 63, 1434, 180, 1180)
      case (.water, 2): return (198, 215, 1147, 310, 804)
      case (.water, 3): return (216, 203, 1024, 520, 716)
      case (.water, _): return (220, 66, 1434, 980, 1220)
      }
    }()
    return DrinkStep(width: spec.w, height: spec.h, image: crop("drink-frames-original.png", x: spec.x, y: spec.y, width: spec.w, height: spec.h, sheet: spec.sheet))
  }

  static func buttonArt(_ kind: DrinkKind) -> (size: CGSize, image: NSImage?) {
    switch kind {
    case .wine: return (CGSize(width: 13, height: 36), crop("wine-button-original.png", x: 235.54, y: 185.98, width: 13, height: 36, sheet: 403))
    case .water: return (CGSize(width: 32, height: 33), crop("water-button-original.png", x: 328.61, y: 227.81, width: 32, height: 33, sheet: 479))
    }
  }
}
