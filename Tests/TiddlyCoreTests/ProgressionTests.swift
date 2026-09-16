import Foundation
import Testing
@testable import TiddlyCore

private func start() -> PetState { PetState.initial() }
private let interval = Progression.pourIntervalMs

@Suite struct ProgressionTests {
  @Test func reachesReferenceAtTwoAutomaticHours() {
    #expect(abs(Progression.markerX(Progression.applyCountedTime(start(), 8 * interval)) - 0.13) < 1e-9)
  }
  @Test func continuesRisingAfterTwoHours() {
    #expect(Progression.markerX(Progression.applyCountedTime(start(), 10 * interval)) > 0.13)
  }
  @Test func wineAdvancesWithoutChangingCountedTime() {
    let next = Progression.giveWine(start())
    #expect(next.countedMs == 0)
    #expect(abs(Progression.markerX(next) - 0.01625) < 1e-9)
  }
  @Test func waterMovesBackOneSip() {
    let withWine = Progression.giveWine(Progression.giveWine(start()))
    #expect(abs(Progression.markerX(Progression.drinkWater(withWine)) - Progression.markerX(Progression.giveWine(start()))) < 1e-9)
  }
  @Test func neverBelowZeroAfterWater() { #expect(Progression.markerX(Progression.drinkWater(start())) == 0) }
  @Test func curvePassesThroughReference() { #expect(abs(Progression.curveY(0.13) - 1) < 1e-9) }
  @Test func processesDelayedIntervalCrossingsOnce() {
    #expect(Progression.applyCountedTime(start(), 31 * 60 * 1000).processedPourInterval == 2)
  }
  @Test func nextPourCountsDownWithinInterval() {
    #expect(Progression.nextPourMs(Progression.applyCountedTime(start(), 5 * 60 * 1000)) == 10 * 60 * 1000)
  }
}

@Suite struct SessionClockTests {
  @Test func creditsOnlyEligibleUnpausedTime() {
    var t: TimeInterval = 0
    let clock = SessionClock(countedMs: 0, paused: false, now: { t })
    t = 5; #expect(clock.update() == 0)
    clock.setEligible(true)
    t = 8; #expect(clock.update() == 3000)
    clock.setPaused(true)
    t = 12; #expect(clock.update() == 3000)
    clock.setPaused(false)
    t = 13; #expect(clock.update() == 4000)
  }
  @Test func doesNotCreditLongGaps() {
    var t: TimeInterval = 0
    let clock = SessionClock(countedMs: 100, paused: false, now: { t })
    clock.setEligible(true)
    t = 10; #expect(clock.update() == 100)
    t = 11; #expect(clock.update() == 1100)
  }
}

@Suite struct StateStoreTests {
  private func tempDir() -> URL {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tiddly-store-\(UUID().uuidString)")
    return dir
  }
  @Test func roundTripsStateWithPrivatePermissions() throws {
    let dir = tempDir(); defer { try? FileManager.default.removeItem(at: dir) }
    let store = StateStore(directory: dir)
    var state = PetState.initial(); state.countedMs = 1234.5; state.characterId = .owl; state.position = PetPosition(x: -32, y: 681)
    try store.save(state)
    #expect(try store.load() == state)
    let mode = try FileManager.default.attributesOfItem(atPath: store.url.path)[.posixPermissions] as? Int
    #expect(mode == 0o600)
    #expect(!FileManager.default.fileExists(atPath: store.url.path + ".new"))
  }
  @Test func readsTheOriginalElectronFileShape() throws {
    let dir = tempDir(); defer { try? FileManager.default.removeItem(at: dir) }
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let json = """
    {"waterCount":53,"version":1,"sessionId":"abc","paused":false,"characterId":"owl","countedMs":7723753.551455941,
     "extraWineCount":49,"processedPourInterval":8,"encouraged":true,"celebrated":true,"position":{"x":-32,"y":681}}
    """
    try json.write(to: dir.appendingPathComponent("pet-state.json"), atomically: true, encoding: .utf8)
    let state = try StateStore(directory: dir).load()
    #expect(state.characterId == .owl && state.waterCount == 53 && state.extraWineCount == 49 && state.position == PetPosition(x: -32, y: 681))
  }
  @Test func migratesMissingWaterCount() throws {
    let dir = tempDir(); defer { try? FileManager.default.removeItem(at: dir) }
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    try #"{"version":1,"characterId":"hedgehog","countedMs":0,"extraWineCount":2}"#.write(to: dir.appendingPathComponent("pet-state.json"), atomically: true, encoding: .utf8)
    #expect(try StateStore(directory: dir).load().waterCount == 0)
  }
  @Test func returnsInitialStateWhenMissing() throws {
    let dir = tempDir()
    #expect(try StateStore(directory: dir).load().countedMs == 0)
  }
}

@Suite struct BridgeModelTests {
  @Test func rejectsMalformedLines() {
    let model = BridgeModel()
    #expect(model.handle(line: "2\tcodex\ta\tb\t1") == .error)
    #expect(model.handle(line: "1\tgemini\ta\tb\t1") == .error)
    #expect(model.handle(line: "1\tcodex\ta b\tb\t1") == .error)
    #expect(model.handle(line: "1\tcodex\ta\tb\t2") == .error)
    #expect(model.handle(line: "1\tcodex\ta\tb") == .error)
  }
  @Test func firesSkillOncePerEvent() {
    let model = BridgeModel(); var fired = 0
    model.onSkillInvoked = { fired += 1 }
    #expect(model.handle(line: "1\tclaude\ts1\te1\t1") == .ok)
    #expect(model.handle(line: "1\tclaude\ts1\te1\t1") == .ok)
    #expect(model.handle(line: "1\tclaude\ts1\te2\t0") == .ok)
    #expect(fired == 1)
    #expect(model.status().message == "1 agent task seen")
  }
  @Test func armsExactlyOneRecentSessionAndActivatesOnce() {
    var now = Date(timeIntervalSince1970: 1000)
    let model = BridgeModel(now: { now })
    #expect(model.arm().message == "Wine served. Agent not connected yet.")
    _ = model.handle(line: "1\tcodex\ts1\te1\t0")
    let armed = model.arm()
    #expect(armed.pending && armed.message == "Ballmer ready for your next prompt.")
    #expect(model.handle(line: "1\tclaude\tother\te2\t0") == .ok)
    #expect(model.handle(line: "1\tcodex\ts1\te3\t0") == .activate)
    #expect(model.handle(line: "1\tcodex\ts1\te4\t0") == .ok)
    #expect(model.arm().message == "Choose one active task before arming Ballmer.")
    now = now.addingTimeInterval(31 * 60)
    #expect(model.arm().message == "Wine served. Agent not connected yet.")
  }
  @Test func pendingExpiresAfterTenMinutes() {
    var now = Date(timeIntervalSince1970: 1000)
    let model = BridgeModel(now: { now })
    _ = model.handle(line: "1\tcodex\ts1\te1\t0")
    #expect(model.arm().pending)
    now = now.addingTimeInterval(11 * 60)
    #expect(!model.status().pending)
    #expect(model.cancel().message == "Request cancelled.")
  }
}

@Suite struct LayoutTests {
  let work = Rect(x: 0, y: 25, width: 1440, height: 875)
  @Test func defaultPositionSitsBottomRight() {
    #expect(Layout.defaultPosition(workArea: work, size: Layout.petWindow) == Point(x: 1240, y: 700))
  }
  @Test func panelSharesPetBottomRightCorner() {
    #expect(Layout.panelOrigin(petOrigin: Point(x: 1000, y: 600), workArea: work) == Point(x: 956, y: 366))
  }
  @Test func panelIsClampedToWorkArea() {
    #expect(Layout.panelOrigin(petOrigin: Point(x: -32, y: 0), workArea: work) == Point(x: 0, y: 25))
    #expect(Layout.panelOrigin(petOrigin: Point(x: 1400, y: 880), workArea: work) == Point(x: 1220, y: 490))
  }
  @Test func graphKeepsMarkerOnCurveAndReferenceAtOne() {
    let g = Graph.geometry(markerX: 0.13)
    #expect(g.curve.count == 41)
    #expect(abs(g.marker.y - g.referenceY) < 1e-9)
    #expect(g.curve.first == Point(x: 10, y: 100))
    #expect(abs(g.curve.last!.y - 15) < 1e-9)
  }
}
