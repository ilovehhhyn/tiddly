import AppKit
import TiddlyCore

/// The pet sprite. Single click toggles the card, dragging moves the window, right-click offers Close Pet.
final class PetView: NSView {
  var character = PetCharacter.hedgehog { didSet { if character != oldValue { needsDisplay = true } } }
  var pose = Pose.idle { didSet { if pose != oldValue { needsDisplay = true } } }
  /// Progress 0…1 of the 1.8 s pour or sip wobble, nil when still.
  var wobble: (kind: DrinkKind, t: CGFloat)? { didSet { needsDisplay = true } }
  var onClick: () -> Void = {}
  var onDragBegan: () -> Void = {}
  var onDrag: (CGFloat, CGFloat) -> Void = { _, _ in }
  var onDragEnded: () -> Void = {}
  var onClosePet: () -> Void = {}

  private var dragStart: CGPoint?
  private var moved = false

  override var isFlipped: Bool { true }
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
  override func resetCursorRects() { addCursorRect(bounds, cursor: .openHand) }

  override func draw(_ dirtyRect: NSRect) {
    guard let image = Artwork.sprite(character, pose), let context = NSGraphicsContext.current?.cgContext else { return }
    context.saveGState()
    if let wobble {
      let (angle, lift) = PetView.transform(wobble.kind, wobble.t)
      let anchor = CGPoint(x: bounds.width / 2, y: bounds.height * 0.9)
      context.translateBy(x: anchor.x, y: anchor.y + lift)
      context.rotate(by: angle * .pi / 180)
      context.translateBy(x: -anchor.x, y: -anchor.y)
    }
    image.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
    context.restoreGState()
  }

  /// Mirrors the `pour` and `sip` CSS keyframes: (rotation degrees, vertical offset).
  static func transform(_ kind: DrinkKind, _ t: CGFloat) -> (CGFloat, CGFloat) {
    let keys: [(CGFloat, CGFloat, CGFloat)] = kind == .wine
      ? [(0, 0, 0), (0.25, -5, -3), (0.6, 4, 0), (1, 0, 0)]
      : [(0, 0, 0), (0.25, 4, -3), (0.7, 4, -3), (1, 0, 0)]
    for index in 1..<keys.count where t <= keys[index].0 {
      let (t0, a0, l0) = keys[index - 1], (t1, a1, l1) = keys[index]
      let f = (t - t0) / (t1 - t0)
      return (a0 + (a1 - a0) * f, l0 + (l1 - l0) * f)
    }
    return (0, 0)
  }

  override func mouseDown(with event: NSEvent) {
    dragStart = NSEvent.mouseLocation; moved = false
    onDragBegan()
  }
  override func mouseDragged(with event: NSEvent) {
    guard let dragStart else { return }
    let location = NSEvent.mouseLocation
    let dx = location.x - dragStart.x, dy = location.y - dragStart.y
    if !moved && hypot(dx, dy) < 4 { return }
    moved = true
    NSCursor.closedHand.set()
    onDrag(dx, -dy)
  }
  override func mouseUp(with event: NSEvent) {
    guard dragStart != nil else { return }
    dragStart = nil
    NSCursor.openHand.set()
    if moved { onDragEnded() } else { onClick() }
  }
  override func rightMouseDown(with event: NSEvent) {
    let menu = NSMenu()
    let item = NSMenuItem(title: "Close Pet", action: #selector(closePet), keyEquivalent: ""); item.target = self
    menu.addItem(item)
    NSMenu.popUpContextMenu(menu, with: event, for: self)
  }
  @objc private func closePet() { onClosePet() }
}

/// Non-interactive layer above everything: the drink animation frames and the speech bubble.
final class OverlayView: NSView {
  var panelOpen = false { didSet { needsDisplay = true } }
  var drink: (kind: DrinkKind, step: Int)? { didSet { needsDisplay = true } }
  var bubble: String? { didSet { needsDisplay = true } }
  var bubbleAlpha: CGFloat = 1 { didSet { needsDisplay = true } }

  override var isFlipped: Bool { true }
  override func hitTest(_ point: NSPoint) -> NSView? { nil }

  override func draw(_ dirtyRect: NSRect) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    if let drink {
      // The 260 × 240 drink scene is anchored at its bottom centre, right-aligned, and scaled down.
      let scale: CGFloat = panelOpen ? 0.36 : 0.3
      let bottom = bounds.height - (panelOpen ? 112 : 58)
      let centerX = bounds.width - 130
      let step = Artwork.drinkStep(drink.kind, drink.step)
      let rect = CGRect(x: centerX - step.width * scale / 2, y: bottom - step.height * scale, width: step.width * scale, height: step.height * scale)
      context.saveGState()
      context.setShadow(offset: CGSize(width: 0, height: -4 * scale), blur: 3, color: NSColor(hex: 0x332b29, alpha: 0.12).cgColor)
      step.image?.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
      context.restoreGState()
    }
    if let bubble, !bubble.isEmpty, bubbleAlpha > 0 {
      let style = TextStyle(font: Theme.font(11), color: Theme.ink)
      let maxWidth = min(195, bounds.width - 16) - 16
      let size = bubble.size(style, width: maxWidth)
      // Anchored 148 pt above the window bottom like the original, but never pushed off the top of the small pet window.
      let top = max(2, bounds.height - 148 - size.height - 12)
      let rect = CGRect(x: bounds.width - 8 - size.width - 16, y: top, width: size.width + 16, height: size.height + 12)
      context.saveGState()
      context.setAlpha(bubbleAlpha)
      context.setShadow(offset: CGSize(width: 0, height: -7), blur: 20, color: NSColor.black.withAlphaComponent(0.15).cgColor)
      Theme.bubble.setFill(); OverlayView.bubblePath(rect).fill()
      context.restoreGState()
      context.saveGState(); context.setAlpha(bubbleAlpha)
      bubble.draw(style, in: rect.insetBy(dx: 8, dy: 6))
      context.restoreGState()
    }
  }

  /// Rounded 14 pt except a 2 pt tail corner at the bottom right, like the CSS `14px 14px 2px 14px`.
  private static func bubblePath(_ r: CGRect) -> NSBezierPath {
    let path = NSBezierPath(), big: CGFloat = 14, tail: CGFloat = 2
    path.move(to: CGPoint(x: r.minX + big, y: r.minY))
    path.line(to: CGPoint(x: r.maxX - big, y: r.minY))
    path.appendArc(withCenter: CGPoint(x: r.maxX - big, y: r.minY + big), radius: big, startAngle: -90, endAngle: 0, clockwise: false)
    path.line(to: CGPoint(x: r.maxX, y: r.maxY - tail))
    path.appendArc(withCenter: CGPoint(x: r.maxX - tail, y: r.maxY - tail), radius: tail, startAngle: 0, endAngle: 90, clockwise: false)
    path.line(to: CGPoint(x: r.minX + big, y: r.maxY))
    path.appendArc(withCenter: CGPoint(x: r.minX + big, y: r.maxY - big), radius: big, startAngle: 90, endAngle: 180, clockwise: false)
    path.line(to: CGPoint(x: r.minX, y: r.minY + big))
    path.appendArc(withCenter: CGPoint(x: r.minX + big, y: r.minY + big), radius: big, startAngle: 180, endAngle: 270, clockwise: false)
    path.close()
    return path
  }
}
