import AppKit
import TiddlyCore

final class PetPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }
}

final class RootView: NSView {
  var onEscape: () -> Void = {}
  override var isFlipped: Bool { true }
  override var acceptsFirstResponder: Bool { true }
  override func keyDown(with event: NSEvent) { if event.keyCode == 53 { onEscape() } else { super.keyDown(with: event) } }
}

struct PetActions {
  var pourWine: () -> Void = {}
  var pourWater: () -> Void = {}
  var togglePause: () -> Void = {}
  var cancelRequest: () -> Void = {}
  var chooseCharacter: (PetCharacter) -> Void = { _ in }
  var moved: (PetPosition) -> Void = { _ in }
}

/// Owns the single floating window that switches between the 176 × 176 pet surface and the 220 × 410 card layout.
final class PetWindowController {
  let window: PetPanel
  private let root = RootView()
  private let panel = PanelView(frame: .zero)
  private let pet = PetView()
  private let overlay = OverlayView()
  private(set) var panelOpen = false
  private(set) var busy = false
  private var petTopLeft: PetPosition
  private var dragOrigin: (window: NSPoint, pet: PetPosition)?
  private var animationTimer: Timer?
  private var bubbleTimer: Timer?
  private var sleepy = false
  private var actions: PetActions

  init(position: PetPosition?, actions: PetActions) {
    self.actions = actions
    let size = Layout.petWindow
    petTopLeft = position.flatMap { Screen.isVisible(Rect(x: $0.x, y: $0.y, width: size.width, height: size.height)) ? $0 : nil }
      ?? { let p = Layout.defaultPosition(workArea: Screen.primaryWorkArea, size: size); return PetPosition(x: p.x, y: p.y) }()
    window = PetPanel(contentRect: Screen.nsRect(Rect(x: petTopLeft.x, y: petTopLeft.y, width: size.width, height: size.height)),
                      styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
    window.isOpaque = false
    window.backgroundColor = .clear
    window.hasShadow = false
    window.level = .floating
    window.isFloatingPanel = true
    window.hidesOnDeactivate = false
    window.isMovableByWindowBackground = false
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
    window.isReleasedWhenClosed = false
    window.contentView = root
    root.addSubview(panel); root.addSubview(pet); root.addSubview(overlay)
    panel.alphaValue = 0; panel.isHidden = true
    wire()
    layout()
  }

  private func wire() {
    root.onEscape = { [weak self] in self?.setPanelOpen(false) }
    pet.onClick = { [weak self] in guard let self else { return }; self.setPanelOpen(!self.panelOpen) }
    pet.onDragBegan = { [weak self] in guard let self else { return }; self.dragOrigin = (self.window.frame.origin, self.petTopLeft) }
    pet.onDrag = { [weak self] dx, dy in
      guard let self, let origin = self.dragOrigin else { return }
      self.window.setFrameOrigin(NSPoint(x: origin.window.x + dx, y: origin.window.y - dy))
      self.petTopLeft = PetPosition(x: (origin.pet.x + dx).rounded(), y: (origin.pet.y + dy).rounded())
    }
    pet.onDragEnded = { [weak self] in guard let self else { return }; self.dragOrigin = nil; self.actions.moved(self.petTopLeft) }
    pet.onClosePet = { [weak self] in self?.hidePet() }
    panel.onClose = { [weak self] in self?.setPanelOpen(false) }
    panel.onWine = { [weak self] in self?.actions.pourWine() }
    panel.onWater = { [weak self] in self?.actions.pourWater() }
    panel.onPause = { [weak self] in self?.actions.togglePause() }
    panel.onCancel = { [weak self] in self?.actions.cancelRequest() }
    panel.onCharacter = { [weak self] in self?.actions.chooseCharacter($0) }
  }

  private func layout() {
    let bounds = root.bounds
    panel.frame = CGRect(x: 10, y: 5, width: PanelView.cardSize.width, height: PanelView.cardSize.height + PanelView.cardTop + 30)
    pet.frame = CGRect(x: bounds.width - 12 - Artwork.spriteSize, y: bounds.height - 3 - Artwork.spriteSize, width: Artwork.spriteSize, height: Artwork.spriteSize)
    overlay.frame = bounds
    overlay.panelOpen = panelOpen
  }

  // MARK: Window state

  func showPet() { window.orderFrontRegardless() }

  func hidePet() {
    if panelOpen { setPanelOpen(false) }
    window.orderOut(nil)
  }

  func setPanelOpen(_ open: Bool) {
    guard open != panelOpen else { return }
    panelOpen = open
    let size = open ? Layout.panelWindow : Layout.petWindow
    let origin: Point = open
      ? Layout.panelOrigin(petOrigin: Point(x: petTopLeft.x, y: petTopLeft.y), workArea: Screen.workArea(near: petTopLeft))
      : Point(x: petTopLeft.x, y: petTopLeft.y)
    window.setFrame(Screen.nsRect(Rect(x: origin.x, y: origin.y, width: size.width, height: size.height)), display: true)
    layout()
    if open {
      panel.isHidden = false
      window.makeKey()
      NSAnimationContext.runAnimationGroup { context in context.duration = 0.16; panel.animator().alphaValue = 1 }
    } else {
      NSAnimationContext.runAnimationGroup({ context in context.duration = 0.16; panel.animator().alphaValue = 0 }) { [weak self] in
        guard let self, !self.panelOpen else { return }
        self.panel.isHidden = true
      }
    }
  }

  var position: PetPosition { petTopLeft }

  func moveToDefault() {
    let p = Layout.defaultPosition(workArea: Screen.primaryWorkArea, size: Layout.petWindow)
    petTopLeft = PetPosition(x: p.x, y: p.y)
    let size = panelOpen ? Layout.panelWindow : Layout.petWindow
    let origin = panelOpen ? Layout.panelOrigin(petOrigin: Point(x: p.x, y: p.y), workArea: Screen.primaryWorkArea) : p
    window.setFrame(Screen.nsRect(Rect(x: origin.x, y: origin.y, width: size.width, height: size.height)), display: true)
    actions.moved(petTopLeft)
  }

  // MARK: Snapshots (development aid)

  /// Renders the current window contents to an image, forcing any pending card fade to finish first.
  func snapshotImage() -> NSImage? {
    panel.alphaValue = panelOpen ? 1 : 0
    root.layoutSubtreeIfNeeded()
    guard let rep = root.bitmapImageRepForCachingDisplay(in: root.bounds) else { return nil }
    root.cacheDisplay(in: root.bounds, to: rep)
    let image = NSImage(size: root.bounds.size); image.addRepresentation(rep)
    return image
  }

  // MARK: Rendering

  func render(_ model: PanelModel, sleepy: Bool) {
    self.sleepy = sleepy
    pet.character = model.character
    if !busy { pet.pose = idlePose(model.character) }
    var shown = model; shown.busy = busy
    if panelOpen { panel.model = shown } else { panel.model = shown; panel.needsDisplay = false }
  }

  private func idlePose(_ character: PetCharacter) -> Pose { sleepy && character == .owl ? .sleepy : .idle }

  func pulse(_ kind: Pulse) { if panelOpen { panel.play(kind) } }

  func showBubble(_ message: String) {
    guard !message.isEmpty else { return }
    overlay.bubble = message; overlay.bubbleAlpha = 1
    bubbleTimer?.invalidate()
    bubbleTimer = Timer.scheduledTimer(withTimeInterval: 4.2, repeats: false) { [weak self] _ in
      guard let self else { return }
      var alpha: CGFloat = 1
      Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { [weak self] timer in
        alpha -= 0.1; self?.overlay.bubbleAlpha = max(0, alpha)
        if alpha <= 0 { timer.invalidate(); self?.overlay.bubble = nil }
      }
    }
  }

  /// Plays the four drink frames plus the sprite wobble over 1.8 s. Ignored while another drink is playing.
  func animate(_ kind: DrinkKind, message: String) {
    guard !busy else { return }
    busy = true
    let poses = Artwork.poses(pet.character, kind)
    pet.pose = poses[Int.random(in: 0..<poses.count)]
    panel.model.busy = true
    showBubble(message)
    let frames: [(Int, TimeInterval)] = [(1, 0.27), (2, 0.36), (3, 0.36), (4, 0.81)]
    let total = frames.reduce(0) { $0 + $1.1 }
    let start = Date().timeIntervalSinceReferenceDate
    animationTimer?.invalidate()
    animationTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { [weak self] timer in
      guard let self else { timer.invalidate(); return }
      let elapsed = Date().timeIntervalSinceReferenceDate - start
      if elapsed >= total {
        timer.invalidate(); self.animationTimer = nil
        self.overlay.drink = nil; self.pet.wobble = nil; self.busy = false
        self.pet.pose = self.idlePose(self.pet.character); self.panel.model.busy = false
        return
      }
      var cursor: TimeInterval = 0, step = 4
      for (frame, duration) in frames { if elapsed < cursor + duration { step = frame; break }; cursor += duration }
      if self.overlay.drink?.step != step { self.overlay.drink = (kind, step) }
      self.pet.wobble = (kind, CGFloat(elapsed / total))
    }
  }
}

/// Converts between AppKit's bottom-left screen space and the top-left space used by the saved position.
enum Screen {
  private static var primaryTop: CGFloat { NSScreen.screens.first?.frame.maxY ?? 0 }

  static func nsRect(_ r: Rect) -> NSRect { NSRect(x: r.x, y: Double(primaryTop) - r.y - r.height, width: r.width, height: r.height) }
  static func rect(_ r: NSRect) -> Rect { Rect(x: r.minX, y: Double(primaryTop) - r.maxY, width: r.width, height: r.height) }

  static var primaryWorkArea: Rect { rect(NSScreen.screens.first?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)) }

  static func workArea(near position: PetPosition) -> Rect {
    let point = nsRect(Rect(x: position.x, y: position.y, width: 1, height: 1)).origin
    let screen = NSScreen.screens.first { $0.frame.contains(point) } ?? NSScreen.screens.min { abs($0.frame.midX - point.x) < abs($1.frame.midX - point.x) }
    return screen.map { rect($0.visibleFrame) } ?? primaryWorkArea
  }

  static func isVisible(_ r: Rect) -> Bool {
    let frame = nsRect(r)
    return NSScreen.screens.contains { $0.visibleFrame.intersects(frame) }
  }
}
