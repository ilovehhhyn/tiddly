import AppKit
import TiddlyCore

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
  static let codexBundleId = "com.openai.codex"
  static let waterMessage = "time for water!!"
  private var state = PetState.initial()
  private var store: StateStore!
  private var clock: SessionClock!
  private var bridge: BridgeServer!
  private var pet: PetWindowController!
  private var statusItem: NSStatusItem!
  private var tick: Timer?
  private var ticks = 0
  private var lockDescriptor: Int32 = -1
  private var signalSources: [DispatchSourceSignal] = []
  private var lastPanelRefresh: (minutes: Int, next: Int, status: String, pending: Bool)?
  private var water: WaterReminder!
  private var waterNudgeVisible = false

  private var supportDirectory: URL {
    FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Tiddly")
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard acquireSingleInstanceLock() else { NSLog("Tiddly is already running."); exit(0) }
    Artwork.registerFonts()
    store = StateStore(directory: supportDirectory)
    state = loadState()
    clock = SessionClock(countedMs: state.countedMs, paused: state.paused)
    water = WaterReminder(startedAt: Date())
    bridge = BridgeServer(model: BridgeModel())
    bridge.model.onSkillInvoked = { [weak self] in self?.skillInvoked() }
    bridge.onStatus = { [weak self] in self?.refresh() }
    bridge.start()
    pet = PetWindowController(position: state.position, actions: PetActions(
      pourWine: { [weak self] in self?.pourWine() },
      pourWater: { [weak self] in self?.pourWater() },
      togglePause: { [weak self] in self?.togglePause() },
      cancelRequest: { [weak self] in _ = self?.bridge.model.cancel(); self?.refresh() },
      chooseCharacter: { [weak self] in self?.state.characterId = $0; self?.save(); self?.refresh() },
      moved: { [weak self] in self?.state.position = $0; self?.save() }))
    refresh(force: true)
    pet.showPet()
    createStatusItem()
    observeSystem()
    installSignalHandlers()
    if let directory = ProcessInfo.processInfo.environment["TIDDLY_SNAPSHOT_DIR"] { writeSnapshots(to: directory); return }
    let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tickOnce() }
    timer.tolerance = 0.2
    tick = timer
  }

  func applicationWillTerminate(_ notification: Notification) { bridge?.stop(); save() }
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { pet?.showPet(); return false }

  // MARK: State

  private func loadState() -> PetState {
    do { return try store.load() } catch {
      NSLog("Tiddly: state file unreadable (%@); starting fresh", String(describing: error))
      try? FileManager.default.moveItem(at: store.url, to: store.url.appendingPathExtension("corrupt"))
      return .initial()
    }
  }

  private func save() { do { try store.save(state) } catch { NSLog("Tiddly: could not save state: %@", String(describing: error)) } }

  private func model() -> PanelModel {
    let status = bridge.model.status()
    let hidden = status.message.range(of: "agent tasks? seen|starting", options: [.regularExpression, .caseInsensitive]) != nil
    return PanelModel(minutes: Int(state.countedMs / 60000), wine: state.extraWineCount, water: state.waterCount,
                      level: Progression.markerX(state), nextPourMinutes: max(1, Int(ceil(Progression.nextPourMs(state) / 60000))),
                      paused: state.paused, status: hidden ? "" : status.message, pending: status.pending, character: state.characterId)
  }

  /// Pushes state to the window. The card is only redrawn when something it shows has changed.
  private func refresh(force: Bool = false) {
    let next = model()
    let key = (next.minutes, next.nextPourMinutes, next.status, next.pending)
    let changed = force || lastPanelRefresh == nil || lastPanelRefresh! != key
    if changed || force { pet.render(next, sleepy: state.countedMs >= Progression.sleepyMs); lastPanelRefresh = key }
  }

  private func tickOnce() {
    let prior = state
    state = Progression.applyCountedTime(state, clock.update())
    refresh()
    if state.processedPourInterval > prior.processedPourInterval {
      pet.animate(.wine, message: state.encouraged && !prior.encouraged ? "Half an hour. Nice work. Tiny cheers." : "")
    }
    if state.celebrated && !prior.celebrated { pet.showBubble("Peak little genius. Onward?") }
    if water.isDue(at: Date()) { remindWater() }
    ticks += 1
    if ticks % 10 == 0 { save() }
  }

  private func pourWine() {
    pet.animate(.wine, message: "")
    state = Progression.giveWine(state)
    _ = bridge.model.arm()
    save(); refresh(force: true); pet.pulse(.advanced)
  }

  private func pourWater() {
    pet.animate(.water, message: "")
    state = Progression.drinkWater(state)
    save(); refresh(force: true); pet.pulse(.retreated)
  }

  /// Hourly nudge. The pet speaks when it is on screen; otherwise the menu bar carries the message until clicked.
  private func remindWater() {
    if pet.window.isVisible { pet.showBubble(AppDelegate.waterMessage) } else { showWaterNudge() }
  }

  private func showWaterNudge() {
    guard !waterNudgeVisible, let button = statusItem.button else { return }
    waterNudgeVisible = true
    statusItem.length = NSStatusItem.variableLength
    button.imagePosition = .imageLeading
    button.title = " \(AppDelegate.waterMessage) "
  }

  private func clearWaterNudge() {
    guard waterNudgeVisible, let button = statusItem.button else { return }
    waterNudgeVisible = false
    button.title = ""
    button.imagePosition = .imageOnly
    statusItem.length = NSStatusItem.squareLength
  }

  private func togglePause() {
    state.paused.toggle(); clock.setPaused(state.paused); save(); refresh(force: true)
    pet.showBubble(state.paused ? "Paused. I’ll save your place." : "Back to tiny business.")
    rebuildStatusMenu()
  }

  private func skillInvoked() {
    let prior = state
    state = Progression.giveWine(state); save(); refresh(force: true)
    pet.animate(.wine, message: "")
    if state.celebrated && !prior.celebrated { pet.showBubble("Peak little genius. Onward?") }
  }

  /// `TIDDLY_SNAPSHOT_DIR=/some/dir` renders pet, card, and a drink frame to PNG files and quits. Used to review drawing without screen capture.
  private func writeSnapshots(to directory: String) {
    let url = URL(fileURLWithPath: directory)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    func write(_ name: String) {
      guard let image = pet.snapshotImage(), let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:]) else { return }
      try? png.write(to: url.appendingPathComponent("\(name).png"))
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      write("pet")
      self.pet.setPanelOpen(true)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        write("card")
        self.pet.animate(.wine, message: "Half an hour. Nice work. Tiny cheers.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
          write("drink")
          self.pet.setPanelOpen(false)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { write("drink-closed"); NSApp.terminate(nil) }
        }
      }
    }
  }

  // MARK: Menu bar

  private func createStatusItem() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let image = NSImage(systemSymbolName: "wineglass", accessibilityDescription: "Tiddly") ?? NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Tiddly") {
      image.isTemplate = true
      statusItem.button?.image = image
    } else { statusItem.button?.title = "T" }
    rebuildStatusMenu()
  }

  private func rebuildStatusMenu() {
    let menu = NSMenu()
    menu.addItem(withTitle: "Show pet", action: #selector(showPet), keyEquivalent: "").target = self
    menu.addItem(withTitle: state.paused ? "Resume" : "Pause", action: #selector(menuTogglePause), keyEquivalent: "").target = self
    menu.addItem(.separator())
    menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q").target = self
    menu.delegate = self
    statusItem.menu = menu
  }

  @objc private func showPet() { clearWaterNudge(); pet.showPet() }
  func menuWillOpen(_ menu: NSMenu) { clearWaterNudge() }
  @objc private func menuTogglePause() { togglePause() }
  @objc private func quit() { NSApp.terminate(nil) }

  // MARK: System observation (event driven, no polling)

  private func observeSystem() {
    let workspace = NSWorkspace.shared.notificationCenter
    let updateForeground: (NSRunningApplication?) -> Void = { [weak self] app in self?.clock.setEligible(app?.bundleIdentifier == AppDelegate.codexBundleId) }
    updateForeground(NSWorkspace.shared.frontmostApplication)
    workspace.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { note in
      updateForeground(note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)
    }
    workspace.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in self?.clock.setPaused(true); self?.save() }
    workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
      guard let self else { return }; self.clock.setPaused(self.state.paused)
    }
    NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
      guard let self else { return }
      let frame = self.pet.window.frame
      if !NSScreen.screens.contains(where: { $0.visibleFrame.intersects(frame) }) { self.pet.moveToDefault() }
    }
  }

  private func installSignalHandlers() {
    for sig in [SIGINT, SIGTERM, SIGHUP] {
      signal(sig, SIG_IGN)
      let source = DispatchSource.makeSignalSource(signal: sig, queue: .main)
      source.setEventHandler { NSApp.terminate(nil) }
      source.resume()
      signalSources.append(source)
    }
  }

  private func acquireSingleInstanceLock() -> Bool {
    try? FileManager.default.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
    let path = supportDirectory.appendingPathComponent("tiddly.lock").path
    lockDescriptor = open(path, O_CREAT | O_RDWR, 0o600)
    guard lockDescriptor >= 0 else { return true }
    return flock(lockDescriptor, LOCK_EX | LOCK_NB) == 0
  }
}
