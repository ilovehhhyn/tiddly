# Tiddly desktop pet

Tiddly is a local desktop pet for macOS. 


## Install and start

Tiddly currently targets Apple-silicon macOS. Install Node.js and npm, plus Apple Command Line Tools for the bundled Swift foreground-app helper, then run:

```sh
npm install
npm start
```


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
========

For the architecture and development workflow, see [internal documentation](docs/INTERNALS.md). Verified and pending platform behavior is tracked in [Tiddly capabilities](docs/CAPABILITIES.md).

`npm run make` creates `out/make/zip/darwin/arm64/Tiddly-darwin-arm64-0.1.0.zip`. The package is ad-hoc signed for local use, not notarized for distribution.
