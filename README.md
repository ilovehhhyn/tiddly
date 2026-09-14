# Tiddly desktop pet

A local macOS desktop companion using Helen's hand-drawn owl, hedgehog, notepad, and drink PNGs verbatim. CSS framing selects existing drawings from those original sheets; generated art never replaces or redraws them. Wine advances the fictional, unbounded Ballmer peak curve; water steps it back by one sip.

## Run

```sh
npm install
npm start
```

Click the pet once to open its opaque notepad. Drag the pet to place it, or right-click it to close it. The menu-bar item provides Show, Pause/Resume, and Quit. State is stored locally in Electron's user-data directory.

Repository-scoped Codex and Claude Code hooks are included. Start a new Codex task in this
repository, open `/hooks`, review the Tiddly hook, and trust it before testing `$ballmer`.

## Verify

```sh
npm run typecheck
npm test
npm run test:desktop
npm run make
```

See [docs/CAPABILITIES.md](docs/CAPABILITIES.md) for verified and unverified native/agent surfaces.
