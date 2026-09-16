# Capability record

Observed September 12, 2026 on the target Mac; native Swift port verified September 15, 2026.

| Surface | Observed | Status |
| --- | --- | --- |
| macOS | 15.5 (24F74), Apple silicon | Available |
| Node / npm | 24.13.0 / 11.6.2 | Available |
| Codex CLI | 0.146.0 | Repository hook installed; requires `/hooks` trust review in a new task |
| Claude Code | 2.1.266 | Repository hook installed; real-session smoke pending |
| Apple developer tools | Command Line Tools, Swift 6.1 | Available |
| Codex foreground identity | In-process `NSWorkspace` app-activation notification | Implemented; no helper process, no polling |
| Idle footprint | Native app, 1 process | ~28 MB resident, 0% CPU while idle |

The local hook helper and both bridge directions pass a synthetic running-app smoke test:
`$ballmer` caused one pet event, and an armed request returned concise Ballmer activation context.
Codex trust review, a real `$ballmer` task, a real Claude `/ballmer` task, signing,
native click-through, and Spaces behavior remain verification gates.
