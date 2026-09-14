# Tiddly desktop pet

Tiddly is a local Electron desktop pet for macOS. It uses Helen’s supplied owl, hedgehog, and drink artwork verbatim. The artwork is not redrawn or replaced.

For the architecture and development workflow, see [internal documentation](docs/INTERNALS.md). Verified and pending platform behavior is tracked in [Tiddly capabilities](docs/CAPABILITIES.md).

## Install and start

Tiddly currently targets Apple-silicon macOS. Install Node.js and npm, plus Apple Command Line Tools for the bundled Swift foreground-app helper, then run:

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

Repository-scoped hooks connect a leading `$ballmer` command in Codex and `/ballmer` in Claude Code to the wine animation and Ballmer skill.

The checked-in hook settings contain the absolute path for this checkout. If you cloned Tiddly elsewhere, replace `/Users/helenhui/tiddly` in `.codex/hooks.json` and `.claude/settings.local.json` with your checkout path. For Codex, start a new task in the repository, open `/hooks`, review the Tiddly hook, and trust it before testing `$ballmer`.

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
