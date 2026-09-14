# Tiddly desktop pet

Tiddly is a local desktop pet for macOS, built with hand-drawn owl, hedgehog, and drink artwork used verbatim.

## Install and start

Tiddly currently targets Apple-silicon macOS. Install [Node.js](https://nodejs.org/) and Apple Command Line Tools (`xcode-select --install`), then install from source:

```sh
git clone https://github.com/ilovehhhyn/tiddly.git
cd tiddly
npm install
npm start
```

`npm install` installs the dependencies and generates repository-local Codex and Claude hook settings using the path to your checkout. Run `npm run setup:hooks` whenever you move the repository. No global install is required.

## Use Tiddly

Choose the owl or hedgehog as your pet.

- Single-click the pet to open the compact opaque panel.
- Drag the pet to reposition it.
- Right-click the pet to close it.
- Use the menu-bar item to Show, Pause or Resume, or Quit Tiddly.

The panel shows a four-cell metrics table above the Ballmer curve. Select **Pour Me Wine** to advance the session along the curve, or **Pour Me Water** to step it back by one sip.

Tiddly stores its state locally in Electron's `userData` directory.

## Connect Codex or Claude Code

Repository-scoped hooks connect a leading `$ballmer` command in Codex and `/ballmer` in Claude Code to the wine animation and Ballmer skill.

For Codex, start a new task in the repository after installation, open `/hooks`, review the generated Tiddly hook, and trust it before testing `$ballmer`. Claude Code reads its generated repository-local settings automatically.

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

`npm run make` creates `out/make/zip/darwin/arm64/Tiddly-darwin-arm64-0.1.0.zip`. The package is ad-hoc signed for local use, not notarized for distribution.

For the architecture and development workflow, see [internal documentation](docs/INTERNALS.md). Verified and pending platform behavior is tracked in [Tiddly capabilities](docs/CAPABILITIES.md).
