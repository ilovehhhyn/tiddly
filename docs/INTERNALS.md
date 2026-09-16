# Tiddly internals

This document is the engineering map for Tiddly. The app is intentionally small: one native AppKit process owns the window, the menu bar item, and persisted state, and one local Unix socket connects supported coding-agent hooks to the pet. There is no Electron, no web renderer, and no polling.

## Runtime shape

- `Package.swift` defines two targets. `TiddlyCore` is pure Foundation logic with tests; `Tiddly` is the AppKit app.
- `Sources/Tiddly/AppDelegate.swift` owns the state, the one-second tick, the menu bar item, sleep and screen notifications, and signal handling. `SIGTERM` and `SIGINT` quit through the normal save path.
- `Sources/Tiddly/PetWindow.swift` creates one floating, non-activating panel. It switches between a 176 × 176 transparent pet surface and a 220 × 410 card layout, mirrors the original drag, click, and Escape behaviour, and plays the drink animations.
- `Sources/Tiddly/PanelView.swift` draws the control card. `PetView.swift` draws the sprite; `OverlayView` in the same file draws the drink frames and the speech bubble.
- `Sources/Tiddly/Artwork.swift` crops Helen's PNG sheets with the same offsets the original CSS used and registers the bundled Gaegu font.
- `Sources/TiddlyCore/Progression.swift` is the pure progression model. Counted work time and wine move the marker forward; water removes one sip-equivalent without allowing a negative position.
- `Sources/TiddlyCore/SessionClock.swift` counts time only while Codex is the foreground app and Tiddly is not paused. Gaps of 10 seconds or more are not credited.
- `Sources/TiddlyCore/StateStore.swift` atomically persists `pet-state.json` with mode `0600` in `~/Library/Application Support/Tiddly/`. The file format is unchanged from the Electron version.

## Efficiency rules

- Foreground detection is event driven. `NSWorkspace` posts an app-activation notification and the clock updates from it. Nothing is spawned and nothing polls.
- The card is only redrawn while it is open and only when a value it shows has changed. The pet is only redrawn when its pose changes. Animations run a 60 Hz timer for their 0.7 to 1.8 second duration and then stop.
- The tick timer runs once a second with 200 ms tolerance so the system can coalesce wake-ups.

## Ballmer bridge

`Sources/Tiddly/BridgeServer.swift` listens on a user-specific Unix socket in the system temporary directory. The socket is mode `0600`. `Sources/TiddlyCore/BridgeModel.swift` holds the protocol and arming rules and is tested directly. `hooks/ballmer-hook.mjs` sends only a provider, sanitized session and event identifiers, and whether the prompt began with the command. It does not send the prompt body to Tiddly.

A direct `$ballmer` invocation in Codex or `/ballmer` invocation in Claude triggers the pet's wine animation. Clicking **Pour Me Wine** also arms one recently seen agent task for ten minutes; the next prompt from that exact task receives context telling it to load the installed Ballmer skill. Arming is rejected when zero or multiple recent tasks make the destination ambiguous.

The hook configuration is repository-scoped in `.codex/hooks.json` and `.claude/settings.local.json`. `npm install` runs `scripts/configure-hooks.mjs`, which generates both ignored files with the current Node executable and checkout path. `npm run setup:hooks` regenerates them after the repository moves. Codex requires the user to review and trust the generated hook in a new task.

## Progression rules

The marker uses sip-equivalents:

```text
max(0, counted time / 15 minutes + wine count - water count)
```

Eight sip-equivalents place the marker at the `0.13` Ballmer reference. The displayed curve is logarithmic and expands its horizontal domain as the marker advances.

## Artwork and UI

Helen's PNG sheets in `assets/source/` are the canonical artwork. `Artwork.swift` crops those pixels; do not trace, redraw, smooth, or generate replacements for the pets or drink frames. The bundled Gaegu font is licensed under the included OFL text. See `assets/README.md` for the asset contract.

Keep drawing code in `Sources/Tiddly/`. Keep anything testable without AppKit in `Sources/TiddlyCore/`. Prefer a small function over a new abstraction unless more than one caller needs it.

## Development and release

```sh
npm test        # swift test: progression, clock, state file, bridge protocol, layout
npm run dev     # build and run attached to the terminal with log output
npm start       # build and open dist/Tiddly.app detached
npm run stop    # quit the running app
npm run make    # build and zip the app under out/make/
```

`scripts/build-app.sh` runs `swift build -c release`, assembles `dist/Tiddly.app` with the five artwork sheets and the Gaegu font, writes `Info.plist` with `LSUIElement` so there is no Dock icon, and ad-hoc signs the bundle. Running the binary inside the bundle directly is the attached, logging mode. Setting `TIDDLY_SNAPSHOT_DIR=/some/dir` renders the pet, the open card, and a drink frame to PNG files and quits, which is how the drawing is reviewed without screen recording permission.

The remaining platform and real-agent verification gates are recorded in `docs/CAPABILITIES.md`. Do not mark those gates complete from synthetic tests alone.
