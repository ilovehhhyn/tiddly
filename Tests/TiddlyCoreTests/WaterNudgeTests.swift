import Testing
@testable import TiddlyCore

@Suite struct WaterNudgeTests {
  @Test func startsQuiet() {
    #expect(WaterNudge().stage == .quiet)
  }

  @Test func aReminderShowsTheLabel() {
    let nudge = WaterNudge()
    #expect(nudge.remind())
    #expect(nudge.stage == .labeled)
  }

  @Test func theLabelCollapsesToTheIconAlone() {
    let nudge = WaterNudge()
    _ = nudge.remind()
    #expect(nudge.collapse())
    #expect(nudge.stage == .icon)
  }

  @Test func collapsingTwiceChangesNothing() {
    let nudge = WaterNudge()
    _ = nudge.remind()
    _ = nudge.collapse()
    #expect(!nudge.collapse())
    #expect(nudge.stage == .icon)
  }

  @Test func collapsingWithoutAReminderChangesNothing() {
    let nudge = WaterNudge()
    #expect(!nudge.collapse())
    #expect(nudge.stage == .quiet)
  }

  @Test func aSecondReminderWhileLabeledIsIgnored() {
    let nudge = WaterNudge()
    _ = nudge.remind()
    #expect(!nudge.remind())
    #expect(nudge.stage == .labeled)
  }

  @Test func aLaterHourRelabelsAnUnreadIcon() {
    let nudge = WaterNudge()
    _ = nudge.remind()
    _ = nudge.collapse()
    #expect(nudge.remind())
    #expect(nudge.stage == .labeled)
  }

  @Test func dismissingClearsTheLabel() {
    let nudge = WaterNudge()
    _ = nudge.remind()
    #expect(nudge.dismiss())
    #expect(nudge.stage == .quiet)
  }

  @Test func dismissingClearsTheIconAlone() {
    let nudge = WaterNudge()
    _ = nudge.remind()
    _ = nudge.collapse()
    #expect(nudge.dismiss())
    #expect(nudge.stage == .quiet)
  }

  @Test func dismissingWhenQuietChangesNothing() {
    let nudge = WaterNudge()
    #expect(!nudge.dismiss())
    #expect(nudge.stage == .quiet)
  }
}
