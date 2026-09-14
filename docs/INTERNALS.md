# Tiddly internals

This document is the engineering map for Tiddly. The app is intentionally small: Electron owns the windows and persisted state, the renderer owns presentation and animation, and one local Unix socket connects supported coding-agent hooks to the pet.

## Runtime shape

- `src/main/app.ts` creates one always-on-top Electron window. It switches between a 176 × 176 transparent pet surface and a 220 × 410 opaque control panel.
- `src/renderer/main.js` handles single-click open and close, dragging, pet selection, drink animations, the graph, and the five-hour sleepy-owl easter egg.
- `src/main/progression.ts` is the pure progression model. Counted work time and wine move the marker forward; water removes one sip-equivalent without allowing a negative position.
- `src/main/session-clock.ts` counts time only while Codex is the foreground app and Tiddly is not paused. Gaps of 10 seconds or more are not credited.
- `src/main/state-store.ts` atomically persists `pet-state.json` with mode `0600` inside Electron's `userData` directory.

## Ballmer bridge

`src/main/bridge.ts` listens on a user-specific Unix socket in the system temporary directory. The socket is mode `0600`. `hooks/ballmer-hook.mjs` sends only a provider, sanitized session and event identifiers, and whether the prompt began with the command. It does not send the prompt body to Tiddly.

A direct `$ballmer` invocation in Codex or `/ballmer` invocation in Claude triggers the pet's wine animation. Clicking **Pour Me Wine** also arms one recently seen agent task for ten minutes; the next prompt from that exact task receives context telling it to load the installed Ballmer skill. Arming is rejected when zero or multiple recent tasks make the destination ambiguous.

The hook configuration is repository-scoped in `.codex/hooks.json` and `.claude/settings.local.json`. Both files use an absolute command path, so a clone in another directory must update that path. Codex also requires the user to review and trust the hook in a new task.

## Progression rules

The marker uses sip-equivalents:

```text
max(0, counted time / 15 minutes + wine count - water count)
```

Eight sip-equivalents place the marker at the `0.13` Ballmer reference. The displayed curve is logarithmic and expands its horizontal domain as the marker advances. A new session keeps the selected pet and window position while resetting progression.

## Artwork and UI

Helen's PNG sheets in `assets/source/` are the canonical artwork. CSS uses cropping and positioning to display those pixels; do not trace, redraw, smooth, or generate replacements for the pets or drink frames. The bundled Gaegu font is licensed under the included OFL text. See `assets/README.md` for the asset contract.

Keep UI code in `src/renderer/main.js` and `src/renderer/styles.css`. Keep progression behavior pure in `src/main/progression.ts`, and keep Electron or filesystem access in `src/main/`. Prefer a small function over a new abstraction unless more than one caller needs it.

## Development and release

Run the full local verification sequence before pushing:

```sh
npm run typecheck
npm test
npm run test:desktop
```

`npm run build` compiles the Swift helper, TypeScript, and renderer. `npm run make` assembles an Apple-silicon `.app`, ad-hoc signs it, and writes a zip under `out/make/zip/darwin/arm64/`. `npm run make:forge` is the Electron Forge packaging path. Build output, dependencies, and logs are ignored by Git.

The remaining platform and real-agent verification gates are recorded in `docs/CAPABILITIES.md`. Do not mark those gates complete from synthetic tests alone.
