import AppKit

extension NSColor {
  convenience init(hex: UInt32, alpha: CGFloat = 1) {
    self.init(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255, blue: CGFloat(hex & 0xff) / 255, alpha: alpha)
  }
}

enum Theme {
  static let ink = NSColor(hex: 0x332b29)
  static let muted = NSColor(hex: 0x675d56)
  static let faint = NSColor(hex: 0x7c7168)
  static let signature = NSColor(hex: 0xa0948b)
  static let closeGlyph = NSColor(hex: 0x97897f)
  static let plum = NSColor(hex: 0x6f3c48)
  static let wine = NSColor(hex: 0x7b3341)
  static let wineDeep = NSColor(hex: 0x8d3448)
  static let winePop = NSColor(hex: 0xd04661)
  static let winePopText = NSColor(hex: 0xb12f4c)
  static let waterPop = NSColor(hex: 0x5b9fba)
  static let waterPopText = NSColor(hex: 0x37697d)
  static let card = NSColor(hex: 0xfffdf8)
  static let cardBorder = NSColor(hex: 0xe2d9cb)
  static let cardShadow = NSColor(hex: 0xeee6da)
  static let cardSoftShadow = NSColor(hex: 0x332b29, alpha: 0.08)
  static let divider = NSColor(hex: 0xe9e1d6)
  static let chart = NSColor(hex: 0xf8e9e9)
  static let track = NSColor(hex: 0xead4d8)
  static let reference = NSColor(hex: 0xcabdac)
  static let bubble = NSColor(hex: 0xfffaf2)
  static let hoverPill = NSColor(hex: 0xfffaf2, alpha: 0.94)
  static let select = NSColor(hex: 0x514640)

  static func font(_ size: CGFloat, bold: Bool = false) -> NSFont {
    let name = bold ? Artwork.boldFontName : Artwork.regularFontName
    if let name, let font = NSFont(name: name, size: size) { return font }
    return NSFont.systemFont(ofSize: size, weight: bold ? .bold : .regular)
  }
}

struct TextStyle {
  var font: NSFont
  var color: NSColor
  var alignment: NSTextAlignment = .left
  var truncate = false

  var attributes: [NSAttributedString.Key: Any] {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = truncate ? .byTruncatingTail : .byWordWrapping
    return [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
  }
}

extension String {
  func draw(_ style: TextStyle, in rect: CGRect) { NSAttributedString(string: self, attributes: style.attributes).draw(in: rect) }
  func size(_ style: TextStyle, width: CGFloat = .greatestFiniteMagnitude) -> CGSize {
    NSAttributedString(string: self, attributes: style.attributes)
      .boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin]).size
  }
}
