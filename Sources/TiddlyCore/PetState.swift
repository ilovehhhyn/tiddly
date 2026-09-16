import Foundation

public enum PetCharacter: String, Codable, CaseIterable { case hedgehog, owl }

public struct PetPosition: Codable, Equatable {
  public var x: Double
  public var y: Double
  public init(x: Double, y: Double) { self.x = x; self.y = y }
}

/// Persisted pet state. The JSON shape matches the original `pet-state.json` exactly so existing files keep working.
public struct PetState: Codable, Equatable {
  public var version: Int
  public var sessionId: String
  public var paused: Bool
  public var characterId: PetCharacter
  public var countedMs: Double
  public var extraWineCount: Int
  public var waterCount: Int
  public var processedPourInterval: Int
  public var encouraged: Bool
  public var celebrated: Bool
  public var position: PetPosition?

  public static func initial() -> PetState {
    PetState(version: 1, sessionId: UUID().uuidString.lowercased(), paused: false, characterId: .hedgehog,
             countedMs: 0, extraWineCount: 0, waterCount: 0, processedPourInterval: 0, encouraged: false, celebrated: false, position: nil)
  }

  public init(version: Int, sessionId: String, paused: Bool, characterId: PetCharacter, countedMs: Double, extraWineCount: Int,
              waterCount: Int, processedPourInterval: Int, encouraged: Bool, celebrated: Bool, position: PetPosition?) {
    self.version = version; self.sessionId = sessionId; self.paused = paused; self.characterId = characterId
    self.countedMs = countedMs; self.extraWineCount = extraWineCount; self.waterCount = waterCount
    self.processedPourInterval = processedPourInterval; self.encouraged = encouraged; self.celebrated = celebrated; self.position = position
  }

  public init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    version = try c.decode(Int.self, forKey: .version)
    guard version == 1 else { throw DecodingError.dataCorruptedError(forKey: .version, in: c, debugDescription: "Unsupported Tiddly state version \(version)") }
    sessionId = try c.decodeIfPresent(String.self, forKey: .sessionId) ?? UUID().uuidString.lowercased()
    paused = try c.decodeIfPresent(Bool.self, forKey: .paused) ?? false
    characterId = try c.decode(PetCharacter.self, forKey: .characterId)
    countedMs = try c.decode(Double.self, forKey: .countedMs)
    extraWineCount = try c.decode(Int.self, forKey: .extraWineCount)
    waterCount = try c.decodeIfPresent(Int.self, forKey: .waterCount) ?? 0
    processedPourInterval = try c.decodeIfPresent(Int.self, forKey: .processedPourInterval) ?? 0
    encouraged = try c.decodeIfPresent(Bool.self, forKey: .encouraged) ?? false
    celebrated = try c.decodeIfPresent(Bool.self, forKey: .celebrated) ?? false
    position = try c.decodeIfPresent(PetPosition.self, forKey: .position)
  }
}
