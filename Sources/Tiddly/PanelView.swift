import AppKit
import TiddlyCore

struct PanelModel {
  var minutes = 0
  var wine = 0
  var water = 0
  var level = 0.0
  var nextPourMinutes = 1
  var paused = false
  var status = ""
  var pending = false
  var character = PetCharacter.hedgehog
  var busy = false
  var peakPercent: Int { Int((100 * level / Progression.referenceX).rounded()) }
}

enum Pulse { case advanced, retreated }

/// The control card. Drawn directly so it matches the original compact CSS layout point for point.
final class PanelView: NSView {
  var model = PanelModel() { didSet { needsDisplay = true } }
  var onWine: () -> Void = {}
  var onWater: () -> Void = {}
  var onPause: () -> Void = {}
  var onCancel: () -> Void = {}
  var onClose: () -> Void = {}
  var onCharacter: (PetCharacter) -> Void = { _ in }

  static let cardTop: CGFloat = 3
  static let cardSize = CGSize(width: 200, height: 244)
  private let card = CGRect(x: 0, y: cardTop, width: cardSize.width, height: cardSize.height)
  private var hovered: Hit?
  private var pulse: (kind: Pulse, start: TimeInterval)?
  private var pulseTimer: Timer?

  private enum Hit { case wine, water, pause, cancel, close, character }

  override var isFlipped: Bool { true }
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

  override init(frame: NSRect) {
    super.init(frame: frame)
    wantsLayer = true
    addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil))
  }
  required init?(coder: NSCoder) { nil }

  // MARK: Layout

  private var content: CGRect { card.insetBy(dx: 12, dy: 0).offsetBy(dx: 0, dy: 8).with(height: card.height - 16) }
  private var header: CGRect { CGRect(x: content.minX, y: content.minY, width: content.width, height: 34) }
  private var chart: CGRect { CGRect(x: content.minX, y: header.maxY + 7, width: content.width, height: 99) }
  private var chartInner: CGRect { CGRect(x: chart.minX + 8, y: chart.minY + 5, width: chart.width - 16, height: chart.height - 5) }
  private var nextRow: CGRect { CGRect(x: content.minX, y: chart.maxY + 4, width: content.width, height: 12) }
  private var actions: CGRect { CGRect(x: content.minX, y: nextRow.maxY, width: content.width, height: 43) }
  private var wineButton: CGRect { CGRect(x: actions.midX - 60, y: actions.midY - 21, width: 48, height: 42) }
  private var waterButton: CGRect { CGRect(x: actions.midX + 12, y: actions.midY - 21, width: 48, height: 42) }
  private var settings: CGRect { CGRect(x: content.minX, y: actions.maxY + 3, width: content.width, height: 18) }
  private var pauseButton: CGRect { CGRect(x: settings.maxX - 48, y: settings.minY, width: 48, height: settings.height) }
  private var characterButton: CGRect { CGRect(x: settings.minX, y: settings.minY, width: 80, height: settings.height) }
  private var statusRow: CGRect { CGRect(x: card.minX + 10, y: card.maxY - 3 - 11, width: card.width - 20, height: 11) }
  private var closeButton: CGRect { CGRect(x: content.maxX - 16, y: content.minY - 3, width: 16, height: 16) }
  private var cancelButton: CGRect {
    let size = "cancel request".size(cancelStyle)
    return CGRect(x: card.minX + 10, y: card.maxY + 22 - size.height - 6, width: size.width + 12, height: size.height + 6)
  }
  private var cancelStyle: TextStyle { TextStyle(font: Theme.font(12), color: Theme.ink) }

  private func hit(_ point: CGPoint) -> Hit? {
    if closeButton.contains(point) { return .close }
    if model.pending && cancelButton.contains(point) { return .cancel }
    if wineButton.contains(point) { return .wine }
    if waterButton.contains(point) { return .water }
    if pauseButton.contains(point) { return .pause }
    if characterButton.contains(point) { return .character }
    return nil
  }

  // MARK: Drawing

  override func draw(_ dirtyRect: NSRect) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    drawCard(context)
    drawStats()
    drawChart(context)
    "Next little pour in \(model.nextPourMinutes)m".draw(TextStyle(font: Theme.font(10), color: Theme.muted, alignment: .center), in: nextRow)
    if !model.busy {
      drawDrinkButton(.wine, in: wineButton, label: "pour me wine")
      drawDrinkButton(.water, in: waterButton, label: "pour me water")
    }
    drawSettings()
    if !model.status.isEmpty { model.status.draw(TextStyle(font: Theme.font(9), color: Theme.muted, alignment: .center, truncate: true), in: statusRow) }
    "tiddly".drawRotated(TextStyle(font: Theme.font(9), color: Theme.signature), at: CGPoint(x: card.maxX - 11, y: card.maxY - 3), degrees: -3, anchor: .bottomRight)
    "×".draw(TextStyle(font: Theme.font(13), color: Theme.closeGlyph, alignment: .center), in: closeButton.offsetBy(dx: 0, dy: -1))
    if model.pending {
      let rect = cancelButton
      Theme.card.setFill(); NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6).fill()
      "cancel request".draw(TextStyle(font: Theme.font(12), color: Theme.ink, alignment: .center), in: rect.insetBy(dx: 0, dy: 3))
    }
  }

  private func drawCard(_ context: CGContext) {
    Theme.cardShadow.setFill(); NSBezierPath(roundedRect: card.offsetBy(dx: 0, dy: 3), xRadius: 13, yRadius: 13).fill()
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -6), blur: 10, color: Theme.cardSoftShadow.cgColor)
    Theme.card.setFill(); NSBezierPath(roundedRect: card, xRadius: 13, yRadius: 13).fill()
    context.restoreGState()
    Theme.cardBorder.setStroke()
    let border = NSBezierPath(roundedRect: card.insetBy(dx: 0.5, dy: 0.5), xRadius: 13, yRadius: 13); border.lineWidth = 1; border.stroke()
  }

  private func drawStats() {
    let cells: [(String, String)] = [("\(model.minutes)", "minutes"), ("\(model.wine)", "wine"), ("\(model.water)", "water"), (String(format: "%.3f", model.level), "level")]
    let cellWidth = header.width / 4
    let top = header.midY - 15
    for (index, (value, label)) in cells.enumerated() {
      let cell = CGRect(x: header.minX + cellWidth * CGFloat(index), y: top, width: cellWidth, height: 30)
      value.draw(TextStyle(font: Theme.font(13), color: Theme.plum, alignment: .center), in: cell)
      label.draw(TextStyle(font: Theme.font(10), color: Theme.muted, alignment: .center), in: cell.offsetBy(dx: 0, dy: 17))
      if index < 3 {
        Theme.divider.setFill(); CGRect(x: cell.maxX - 0.5, y: cell.minY + 2, width: 1, height: cell.height - 4).fill()
      }
    }
  }

  private func pulseProgress() -> (kind: Pulse, t: CGFloat)? {
    guard let pulse else { return nil }
    let t = CGFloat((Date().timeIntervalSinceReferenceDate - pulse.start) / 0.7)
    return t >= 1 ? nil : (pulse.kind, t)
  }

  private func drawChart(_ context: CGContext) {
    Theme.chart.setFill(); NSBezierPath(roundedRect: chart, xRadius: 10, yRadius: 10).fill()
    let inner = chartInner
    let pulse = pulseProgress()
    let labelRow = CGRect(x: inner.minX, y: inner.minY, width: inner.width, height: 14)
    "Ballmer peak".draw(TextStyle(font: Theme.font(11, bold: true), color: Theme.ink), in: labelRow.offsetBy(dx: 0, dy: 1))
    let percent = "\(model.peakPercent)%"
    let percentStyle = TextStyle(font: Theme.font(12, bold: true), color: pulseColor(pulse, base: Theme.wine, wine: Theme.winePopText, water: Theme.waterPopText), alignment: .right)
    let percentSize = percent.size(percentStyle)
    let percentRect = CGRect(x: inner.maxX - percentSize.width, y: labelRow.minY, width: percentSize.width, height: percentSize.height)
    context.saveGState()
    if let pulse { let s = bump(pulse.t, peak: pulse.kind == .advanced ? 1.35 : 1.25); context.scaleAround(percentRect.center, s) }
    percent.draw(percentStyle, in: percentRect)
    context.restoreGState()

    let track = CGRect(x: inner.minX, y: labelRow.maxY + 1, width: inner.width, height: 3)
    Theme.track.setFill(); NSBezierPath(roundedRect: track, xRadius: 1.5, yRadius: 1.5).fill()
    let fill = track.with(width: track.width * CGFloat(min(100, max(0, model.peakPercent))) / 100)
    if fill.width > 0 { Theme.wineDeep.setFill(); NSBezierPath(roundedRect: fill, xRadius: 1.5, yRadius: 1.5).fill() }

    // The SVG view box is 300 × 120 fitted into 160 × 69 (xMidYMid meet).
    let graphBox = CGRect(x: inner.minX, y: track.maxY + 3, width: inner.width, height: 69)
    let scale = min(graphBox.width / 300, graphBox.height / 120)
    let origin = CGPoint(x: graphBox.midX - 150 * scale, y: graphBox.midY - 60 * scale)
    func map(_ p: Point) -> CGPoint { CGPoint(x: origin.x + CGFloat(p.x) * scale, y: origin.y + CGFloat(p.y) * scale) }
    let geometry = Graph.geometry(markerX: model.level)
    let reference = NSBezierPath()
    reference.move(to: map(Point(x: 0, y: geometry.referenceY))); reference.line(to: map(Point(x: 300, y: geometry.referenceY)))
    reference.lineWidth = scale; reference.setLineDash([3 * scale, 4 * scale], count: 2, phase: 0); Theme.reference.setStroke(); reference.stroke()
    let curve = NSBezierPath()
    for (index, point) in geometry.curve.enumerated() { index == 0 ? curve.move(to: map(point)) : curve.line(to: map(point)) }
    curve.lineWidth = 3 * scale; curve.lineCapStyle = .round
    curve.setLineDash([5 * scale, 1 * scale, 11 * scale, 1 * scale], count: 4, phase: 0); Theme.wine.setStroke(); curve.stroke()
    "0".draw(TextStyle(font: Theme.font(10 * scale), color: Theme.faint), in: CGRect(x: origin.x + 10 * scale, y: origin.y + 108 * scale, width: 20, height: 12))
    let marker = map(geometry.marker)
    var radius = 5 * scale
    var markerColor = Theme.wine
    if let pulse {
      radius *= bump(pulse.t, peak: pulse.kind == .advanced ? 2.2 : 1.8)
      markerColor = pulseColor(pulse, base: Theme.wine, wine: Theme.winePop, water: Theme.waterPop)
    }
    let dot = NSBezierPath(ovalIn: CGRect(x: marker.x - radius, y: marker.y - radius, width: radius * 2, height: radius * 2))
    markerColor.setFill(); dot.fill(); NSColor.white.setStroke(); dot.lineWidth = 2 * scale; dot.stroke()
  }

  private func bump(_ t: CGFloat, peak: CGFloat) -> CGFloat { t < 0.4 ? 1 + (peak - 1) * (t / 0.4) : peak - (peak - 1) * ((t - 0.4) / 0.6) }

  private func pulseColor(_ pulse: (kind: Pulse, t: CGFloat)?, base: NSColor, wine: NSColor, water: NSColor) -> NSColor {
    guard let pulse else { return base }
    let target = pulse.kind == .advanced ? wine : water
    let mix = (bump(pulse.t, peak: 2) - 1)
    return base.blended(withFraction: mix, of: target) ?? base
  }

  private func drawDrinkButton(_ kind: DrinkKind, in rect: CGRect, label: String) {
    let isHovered = hovered == (kind == .wine ? .wine : .water)
    let art = Artwork.buttonArt(kind)
    var artRect = CGRect(x: rect.midX - art.size.width / 2, y: rect.midY - art.size.height / 2, width: art.size.width, height: art.size.height)
    if isHovered { artRect = artRect.offsetBy(dx: 0, dy: -2) }
    art.image?.draw(in: artRect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
    if isHovered {
      let style = TextStyle(font: Theme.font(11), color: Theme.ink, alignment: .center)
      let size = label.size(style)
      let pill = CGRect(x: rect.midX - size.width / 2 - 7, y: rect.minY - 10, width: size.width + 14, height: size.height + 3)
      Theme.hoverPill.setFill(); NSBezierPath(roundedRect: pill, xRadius: pill.height / 2, yRadius: pill.height / 2).fill()
      label.draw(style, in: pill.insetBy(dx: 7, dy: 1))
    }
  }

  private func drawSettings() {
    let style = TextStyle(font: Theme.font(11), color: Theme.ink)
    let row = settings
    "pet".draw(style, in: CGRect(x: row.minX + 2, y: row.minY + 2, width: 30, height: row.height))
    let name = model.character.rawValue
    let nameRect = CGRect(x: row.minX + 2 + "pet ".size(style).width, y: row.minY + 2, width: 60, height: row.height)
    name.draw(style, in: nameRect)
    let caret = NSBezierPath()
    let caretX = nameRect.minX + name.size(style).width + 6, caretY = row.midY + 2
    caret.move(to: CGPoint(x: caretX, y: caretY - 2)); caret.line(to: CGPoint(x: caretX + 5, y: caretY - 2)); caret.line(to: CGPoint(x: caretX + 5, y: caretY + 3)); caret.close()
    Theme.select.setFill(); caret.fill()
    (model.paused ? "Resume" : "Pause").draw(TextStyle(font: Theme.font(11), color: Theme.ink, alignment: .right), in: pauseButton.insetBy(dx: 6, dy: 0).offsetBy(dx: 0, dy: 2))
  }

  // MARK: Interaction

  func play(_ kind: Pulse) {
    pulse = (kind, Date().timeIntervalSinceReferenceDate)
    pulseTimer?.invalidate()
    pulseTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { [weak self] timer in
      guard let self else { timer.invalidate(); return }
      self.needsDisplay = true
      if self.pulseProgress() == nil { timer.invalidate(); self.pulse = nil; self.needsDisplay = true }
    }
  }

  override func mouseMoved(with event: NSEvent) {
    let next = hit(convert(event.locationInWindow, from: nil))
    if next != hovered { hovered = next; needsDisplay = true }
  }
  override func mouseExited(with event: NSEvent) { if hovered != nil { hovered = nil; needsDisplay = true } }

  override func mouseDown(with event: NSEvent) {
    let point = convert(event.locationInWindow, from: nil)
    switch hit(point) {
    case .wine: if !model.busy { onWine() }
    case .water: if !model.busy { onWater() }
    case .pause: onPause()
    case .cancel: onCancel()
    case .close: onClose()
    case .character:
      let menu = NSMenu()
      for character in PetCharacter.allCases {
        let item = NSMenuItem(title: character.rawValue, action: #selector(chooseCharacter(_:)), keyEquivalent: "")
        item.target = self; item.representedObject = character.rawValue; item.state = character == model.character ? .on : .off
        menu.addItem(item)
      }
      menu.popUp(positioning: nil, at: CGPoint(x: characterButton.minX, y: characterButton.maxY), in: self)
    case nil: break
    }
  }

  @objc private func chooseCharacter(_ sender: NSMenuItem) {
    guard let raw = sender.representedObject as? String, let character = PetCharacter(rawValue: raw) else { return }
    onCharacter(character)
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    guard !isHidden, alphaValue > 0 else { return nil }
    let local = convert(point, from: superview)
    return card.contains(local) || (model.pending && cancelButton.contains(local)) ? self : nil
  }
}

extension CGRect {
  var center: CGPoint { CGPoint(x: midX, y: midY) }
  func with(width: CGFloat? = nil, height: CGFloat? = nil) -> CGRect { CGRect(x: minX, y: minY, width: width ?? self.width, height: height ?? self.height) }
}

extension CGContext {
  func scaleAround(_ point: CGPoint, _ scale: CGFloat) { translateBy(x: point.x, y: point.y); scaleBy(x: scale, y: scale); translateBy(x: -point.x, y: -point.y) }
}

extension String {
  enum Anchor { case bottomRight }
  func drawRotated(_ style: TextStyle, at point: CGPoint, degrees: CGFloat, anchor: Anchor) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    let size = self.size(style)
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    context.rotate(by: degrees * .pi / 180)
    self.draw(style, in: CGRect(x: -size.width, y: -size.height, width: size.width, height: size.height))
    context.restoreGState()
  }
}
