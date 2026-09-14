# Tiddly desktop pet

Tiddly is a local Electron desktop pet for macOS. It uses Helen’s supplied owl, hedgehog, and drink artwork verbatim. The artwork is not redrawn or replaced.

For implementation status, including verified and unverified native and agent surfaces, see [Tiddly capabilities](docs/CAPABILITIES.md).

## Install and start

Tiddly currently targets macOS and includes a Swift foreground-app helper. Install Node.js and npm, then run:

```sh
npm install
npm start
```

## Use Tiddly

Choose the owl or hedgehog as your pet.

- Single-click the pet to open the compact opaque panel.
- Drag the pet to reposition it.
- Right-click the pet to close it.
- Use the menu-bar item to Show, Pause or Resume, or Quit Tiddly.

The panel shows a four-cell metrics table above the Ballmer curve. Select **Pour Me Wine** to advance the session along the curve, or **Pour Me Water** to step it back by one sip.

Tiddly stores its state locally in Electron’s `userData` directory.

## Connect Codex or Claude Code

Repository-scoped hooks connect a leading `$ballmer` command in Codex and `/ballmer` in Claude Code to the wine animation.

For Codex, start a new task in this repository, open `/hooks`, review the Tiddly hook, and trust it before testing `$ballmer`.

## Verify

```sh
npm run typecheck
npm test
npm run test:desktop
```

## Package

```sh
npm run make
npm run make:forge
```
