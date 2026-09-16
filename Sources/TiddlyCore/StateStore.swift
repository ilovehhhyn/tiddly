import Foundation

/// Atomically persists `pet-state.json` with mode 0600.
public final class StateStore {
  public let url: URL

  public init(directory: URL) { url = directory.appendingPathComponent("pet-state.json") }

  public func load() throws -> PetState {
    guard FileManager.default.fileExists(atPath: url.path) else { return .initial() }
    return try JSONDecoder().decode(PetState.self, from: Data(contentsOf: url))
  }

  public func save(_ state: PetState) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let draft = url.appendingPathExtension("new")
    try encoder.encode(state).write(to: draft)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: draft.path)
    guard rename(draft.path, url.path) == 0 else { throw CocoaError(.fileWriteUnknown) }
  }
}
