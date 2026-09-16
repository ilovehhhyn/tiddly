import Foundation

/// Pure progression model. Counted work time and wine move the marker forward; water moves it back one sip.
public enum Progression {
  public static let pourIntervalMs: Double = 15 * 60 * 1000
  public static let referenceX: Double = 0.13
  public static let encouragementMs: Double = 30 * 60 * 1000
  public static let sleepyMs: Double = 5 * 60 * 60 * 1000

  public static func markerX(_ state: PetState) -> Double {
    let sips = max(0, state.countedMs / pourIntervalMs + Double(state.extraWineCount) - Double(state.waterCount))
    return referenceX * sips / 8
  }

  public static func curveY(_ x: Double) -> Double { log1p(x / referenceX) / log(2) }

  public static func nextPourMs(_ state: PetState) -> Double {
    pourIntervalMs - state.countedMs.truncatingRemainder(dividingBy: pourIntervalMs)
  }

  public static func applyCountedTime(_ state: PetState, _ countedMs: Double) -> PetState {
    var next = state
    next.countedMs = max(state.countedMs, countedMs)
    next.processedPourInterval = max(state.processedPourInterval, Int(floor(next.countedMs / pourIntervalMs)))
    next.encouraged = state.encouraged || next.countedMs >= encouragementMs
    next.celebrated = state.celebrated || markerX(next) >= referenceX
    return next
  }

  public static func giveWine(_ state: PetState) -> PetState {
    var next = state
    next.extraWineCount += 1
    next.celebrated = state.celebrated || markerX(next) >= referenceX
    return next
  }

  public static func drinkWater(_ state: PetState) -> PetState {
    var next = state
    next.waterCount += 1
    return next
  }
}
