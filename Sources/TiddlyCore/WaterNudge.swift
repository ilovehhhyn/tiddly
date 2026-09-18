/// How the menu bar is currently carrying the water reminder.
///
/// The label is the part that widens the status item, and a status item that grows too wide can be
/// dropped from a crowded menu bar — on a notched Mac especially. So the label is always temporary:
/// it collapses on its own to a bare changed icon, which is what persists until the reminder is read.
public enum WaterNudgeStage: Equatable { case quiet, labeled, icon }

public final class WaterNudge {
  public private(set) var stage: WaterNudgeStage = .quiet

  public init() {}

  /// Shows the wide label. Ignored while one is already up; an unread icon is relabeled by a later hour.
  public func remind() -> Bool {
    guard stage != .labeled else { return false }
    stage = .labeled
    return true
  }

  /// Drops the label and keeps the changed icon. Only meaningful while a label is up.
  public func collapse() -> Bool {
    guard stage == .labeled else { return false }
    stage = .icon
    return true
  }

  /// Read and acknowledged: back to the ordinary wine glass.
  public func dismiss() -> Bool {
    guard stage != .quiet else { return false }
    stage = .quiet
    return true
  }
}
