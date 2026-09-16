import Foundation

public struct BridgeStatus: Equatable {
  public let connectedSessions: Int
  public let pending: Bool
  public let message: String
}

public enum BridgeReply: String { case ok, activate, error }

/// Protocol and arming rules for the local agent bridge. Transport-free so it can be tested directly.
public final class BridgeModel {
  public static let sessionWindow: TimeInterval = 30 * 60
  public static let armWindow: TimeInterval = 10 * 60
  public var onSkillInvoked: () -> Void = {}

  private struct Session { let provider: String; let id: String; var lastSeen: Date; var key: String { "\(provider):\(id)" } }
  private struct Pending { let sessionKey: String; let expiresAt: Date }
  private let now: () -> Date
  private var sessions: [String: Session] = [:]
  private var pending: Pending?
  private var recentEvents = Set<String>()

  public init(now: @escaping () -> Date = Date.init) { self.now = now }

  public func arm() -> BridgeStatus {
    expire()
    let active = sessions.values.filter { now().timeIntervalSince($0.lastSeen) < BridgeModel.sessionWindow }
    guard active.count == 1, let session = active.first else {
      return status(active.isEmpty ? "Wine served. Agent not connected yet." : "Choose one active task before arming Ballmer.")
    }
    pending = Pending(sessionKey: session.key, expiresAt: now().addingTimeInterval(BridgeModel.armWindow))
    return status("Ballmer ready for your next prompt.")
  }

  public func cancel() -> BridgeStatus { pending = nil; return status("Request cancelled.") }

  public func status(_ message: String? = nil) -> BridgeStatus {
    expire()
    let fallback = pending != nil ? "Ballmer ready for your next prompt." : "\(sessions.count) agent task\(sessions.count == 1 ? "" : "s") seen"
    return BridgeStatus(connectedSessions: sessions.count, pending: pending != nil, message: message ?? fallback)
  }

  /// Handles one `version\tprovider\tsession\tevent\tinvoked` line from the hook.
  public func handle(line: String) -> BridgeReply {
    let parts = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
    guard parts.count == 5, parts[0] == "1", parts[1] == "codex" || parts[1] == "claude",
          BridgeModel.isSafeId(parts[2]), BridgeModel.isSafeId(parts[3]), parts[4] == "0" || parts[4] == "1" else { return .error }
    let session = Session(provider: parts[1], id: parts[2], lastSeen: now())
    sessions[session.key] = session
    if parts[4] == "1" && !recentEvents.contains(parts[3]) { recentEvents.insert(parts[3]); onSkillInvoked() }
    expire()
    let consumes = pending?.sessionKey == session.key
    if consumes { pending = nil }
    return consumes ? .activate : .ok
  }

  private func expire() { if let pending, pending.expiresAt <= now() { self.pending = nil } }

  static func isSafeId(_ value: String) -> Bool {
    !value.isEmpty && value.count <= 160 && value.unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) || "_.:-".unicodeScalars.contains($0) }
  }
}
