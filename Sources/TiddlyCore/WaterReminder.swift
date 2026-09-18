import Foundation

/// Decides when the hourly water nudge is due.
///
/// Wall-clock hours from 10:00 through 01:00 each get one reminder. The hour Tiddly launched in is
/// treated as already reminded, so starting up at 10:37 waits for 11:00 rather than nudging at once.
/// Because a slot fires on first sighting rather than on the stroke of the hour, a machine that sleeps
/// through several slots produces a single catch-up reminder on wake, not a backlog.
public final class WaterReminder {
  private struct Slot: Equatable {
    let year: Int, month: Int, day: Int, hour: Int

    init(date: Date, calendar: Calendar) {
      let parts = calendar.dateComponents([.year, .month, .day, .hour], from: date)
      year = parts.year ?? 0; month = parts.month ?? 0; day = parts.day ?? 0; hour = parts.hour ?? 0
    }
  }

  public static func isReminderHour(_ hour: Int) -> Bool { hour >= 10 || hour <= 1 }

  private let calendar: Calendar
  private var lastSlot: Slot

  public init(startedAt now: Date, calendar: Calendar = .current) {
    self.calendar = calendar
    lastSlot = Slot(date: now, calendar: calendar)
  }

  /// True at most once per reminder hour. Call as often as you like; it is cheap and idempotent within a slot.
  public func isDue(at now: Date) -> Bool {
    let slot = Slot(date: now, calendar: calendar)
    guard slot != lastSlot else { return false }
    lastSlot = slot
    return WaterReminder.isReminderHour(slot.hour)
  }
}
