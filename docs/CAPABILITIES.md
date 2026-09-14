# Capability record

Observed September 12, 2026 on the target Mac.

| Surface | Observed | Status |
| --- | --- | --- |
| macOS | 15.5 (24F74), Apple silicon | Available |
| Node / npm | 24.13.0 / 11.6.2 | Available |
| Codex CLI | 0.146.0 | Repository hook installed; requires `/hooks` trust review in a new task |
| Claude Code | 2.1.266 | Repository hook installed; real-session smoke pending |
| Apple developer tools | Command Line Tools | Available |
| Codex foreground identity | AppKit `NSWorkspace.frontmostApplication` helper | Implemented; native transition smoke pending |

The local hook helper and both bridge directions pass a synthetic running-app smoke test:
`$ballmer` caused one pet event, and an armed request returned concise Ballmer activation context.
Codex trust review, a real `$ballmer` task, a real Claude `/ballmer` task, signing,
native click-through, and Spaces behavior remain verification gates.
