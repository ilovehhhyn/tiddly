# Tiddly - get tiddly to code!

Tiddly is a local desktop pet for macOS that helps you get in the flow  🍾 🥂 🍷 ✨ 
<img width="195" height="164" alt="Screenshot 2026-09-14 at 1 26 07 AM" src="https://github.com/user-attachments/assets/01e47d55-6c40-4760-8436-ca85ba8b9397" />

Visit the [Tiddly website](https://ilovehhhyn.github.io/tiddly/).

## Install and start

Tiddly is a native Swift app for Apple-silicon macOS 13 or newer. Prereqs: [Node.js](https://nodejs.org/) for the agent hooks and Apple Command Line Tools (`xcode-select --install`) for the Swift compiler.

```sh
git clone https://github.com/ilovehhhyn/tiddly.git
cd tiddly
npm install
npm start
```

`npm start` builds `dist/Tiddly.app` and opens it. Tiddly runs on its own from that point: you can close the terminal, and it keeps going until you quit it from the wine-glass menu bar icon or with:

```sh
npm run stop
```

if you closed tiddly, relaunch it by navigating to the `tiddly` repo and running `npm start` again. To run it attached to the terminal with log output, use `npm run dev`.

## Connect Codex or Claude Code

Repository-scoped hooks connect a leading `$ballmer` command in Codex and `/ballmer` in Claude Code to the wine animation and Ballmer skill.

For Codex, start a new task in the repository after installation, open `/hooks`, review the generated Tiddly hook, and trust it before testing `$ballmer`. 

## Verify

```sh
npm test
```

## Package

```sh
npm run make
```

`npm run make` writes `out/make/Tiddly-darwin-arm64-0.1.0.zip`. The app is ad-hoc signed for local use, not notarized for distribution.

For the architecture and development workflow, see [internal documentation](docs/INTERNALS.md). Verified and pending platform behavior is tracked in [Tiddly capabilities](docs/CAPABILITIES.md).
