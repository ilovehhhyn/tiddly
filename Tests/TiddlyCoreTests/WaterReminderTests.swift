import Foundation
import Testing
@testable import TiddlyCore

private let utc: Calendar = {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: "UTC")!
  return calendar
}()

private func at(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
  utc.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))!
}

@Suite struct WaterReminderTests {
  @Test func remindsThroughTheLateHours() {
    #expect(WaterReminder.isReminderHour(10))
    #expect(WaterReminder.isReminderHour(17))
    #expect(WaterReminder.isReminderHour(23))
    #expect(WaterReminder.isReminderHour(0))
    #expect(WaterReminder.isReminderHour(1))
  }

  @Test func staysQuietOvernight() {
    #expect(!WaterReminder.isReminderHour(2))
    #expect(!WaterReminder.isReminderHour(6))
    #expect(!WaterReminder.isReminderHour(9))
  }

  @Test func doesNotFireForTheHourItLaunchedIn() {
    let reminder = WaterReminder(startedAt: at(18, 10, 37), calendar: utc)
    #expect(!reminder.isDue(at: at(18, 10, 38)))
    #expect(!reminder.isDue(at: at(18, 10, 59)))
  }

  @Test func firesOnceWhenTheHourTurns() {
    let reminder = WaterReminder(startedAt: at(18, 10, 37), calendar: utc)
    #expect(reminder.isDue(at: at(18, 11, 0)))
    #expect(!reminder.isDue(at: at(18, 11, 0)))
    #expect(!reminder.isDue(at: at(18, 11, 30)))
  }

  @Test func skipsHoursOutsideTheWindow() {
    let reminder = WaterReminder(startedAt: at(18, 1, 30), calendar: utc)
    #expect(!reminder.isDue(at: at(18, 2, 0)))
    #expect(!reminder.isDue(at: at(18, 9, 0)))
    #expect(reminder.isDue(at: at(18, 10, 0)))
  }

  @Test func catchesUpOnceAfterASleepGap() {
    let reminder = WaterReminder(startedAt: at(18, 10, 0), calendar: utc)
    #expect(reminder.isDue(at: at(18, 13, 20)))
    #expect(!reminder.isDue(at: at(18, 13, 21)))
  }

  @Test func remindsAgainTheFollowingDayAtTheSameHour() {
    let reminder = WaterReminder(startedAt: at(18, 14, 0), calendar: utc)
    #expect(reminder.isDue(at: at(19, 14, 0)))
  }
}
