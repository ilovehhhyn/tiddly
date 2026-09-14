import AppKit

if let identifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier {
    print(identifier)
}
