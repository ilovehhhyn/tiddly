import Foundation

/// Counts time only while the agent app is frontmost and the pet is not paused. Gaps of 10 seconds or more are not credited.
public final class SessionClock {
  public static let maxCreditedGap: TimeInterval = 10
  private let now: () -> TimeInterval
  private var baseline: TimeInterval
  private var eligible = false
  private var paused: Bool
  private var countedMs: Double

  public init(countedMs: Double, paused: Bool, now: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }) {
    self.now = now; self.countedMs = countedMs; self.paused = paused; baseline = now()
  }

  public func setPaused(_ paused: Bool) { _ = update(); self.paused = paused; baseline = now() }
  public func setEligible(_ eligible: Bool) { _ = update(); self.eligible = eligible }

  @discardableResult
  public func update() -> Double {
    let current = now()
    let elapsed = current - baseline
    baseline = current
    if !paused && eligible && elapsed >= 0 && elapsed < SessionClock.maxCreditedGap { countedMs += elapsed * 1000 }
    return countedMs
  }
}
