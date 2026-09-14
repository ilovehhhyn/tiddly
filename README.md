# Tiddly desktop pet

Tiddly is a local desktop pet for macOS, built with hand-drawn owl, hedgehog, and drink artwork used verbatim.

## Install and start

Tiddly currently targets Apple-silicon macOS. Prereqs: [Node.js](https://nodejs.org/) and Apple Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/ilovehhhyn/tiddly.git
cd tiddly
npm install
npm start```

## Connect Codex or Claude Code

Repository-scoped hooks connect a leading `$ballmer` command in Codex and `/ballmer` in Claude Code to the wine animation and Ballmer skill.

For Codex, start a new task in the repository after installation, open `/hooks`, review the generated Tiddly hook, and trust it before testing `$ballmer`. 

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
