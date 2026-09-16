import Foundation
import TiddlyCore

/// Listens on the user-specific Unix socket the hook script connects to. One short line in, one word out.
final class BridgeServer {
  let model: BridgeModel
  let path: String
  var onStatus: () -> Void = {}
  private var listener: Int32 = -1
  private var source: DispatchSourceRead?
  private let queue = DispatchQueue(label: "app.tiddly.bridge")

  init(model: BridgeModel) {
    self.model = model
    var directory = ProcessInfo.processInfo.environment["TMPDIR"] ?? NSTemporaryDirectory()
    while directory.count > 1 && directory.hasSuffix("/") { directory.removeLast() }
    path = "\(directory)/ballmer-\(getuid()).sock"
  }

  func start() {
    unlink(path)
    listener = socket(AF_UNIX, SOCK_STREAM, 0)
    guard listener >= 0 else { NSLog("Tiddly: cannot create bridge socket"); return }
    var address = sockaddr_un()
    address.sun_family = sa_family_t(AF_UNIX)
    let bytes = path.utf8CString
    guard bytes.count <= MemoryLayout.size(ofValue: address.sun_path) else { NSLog("Tiddly: bridge path too long"); return }
    withUnsafeMutablePointer(to: &address.sun_path) { pointer in
      pointer.withMemoryRebound(to: CChar.self, capacity: bytes.count) { destination in
        bytes.withUnsafeBufferPointer { destination.update(from: $0.baseAddress!, count: bytes.count) }
      }
    }
    let length = socklen_t(MemoryLayout<sockaddr_un>.size)
    let bound = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(listener, $0, length) } }
    guard bound == 0, chmod(path, 0o600) == 0, listen(listener, 8) == 0 else { NSLog("Tiddly: cannot listen on %@", path); close(listener); return }
    let source = DispatchSource.makeReadSource(fileDescriptor: listener, queue: queue)
    source.setEventHandler { [weak self] in
      guard let self else { return }
      let client = accept(self.listener, nil, nil)
      if client >= 0 { self.serve(client) }
    }
    source.resume()
    self.source = source
  }

  func stop() {
    source?.cancel(); source = nil
    if listener >= 0 { close(listener); listener = -1 }
    unlink(path)
  }

  private func serve(_ client: Int32) {
    defer { close(client) }
    var timeout = timeval(tv_sec: 1, tv_usec: 0)
    setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 1024)
    while true {
      let count = read(client, &buffer, buffer.count)
      if count <= 0 { break }
      data.append(buffer, count: count)
      if data.count > 2048 { return }
    }
    let line = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    var reply = BridgeReply.error
    DispatchQueue.main.sync { reply = self.model.handle(line: line); self.onStatus() }
    let response = Array("\(reply.rawValue)\n".utf8)
    _ = response.withUnsafeBufferPointer { write(client, $0.baseAddress, $0.count) }
  }
}
