# Tiddly native Swift port

Date: 2026-09-15

## Goal

Replace the Electron app with a native AppKit app so Tiddly can run in the background all day without a noticeable footprint. Keep every user-visible behaviour, the saved state file, and the agent hook protocol unchanged.

## Motivation

Measured idle cost of the Electron build was four processes, about 125 MB resident and 0.7% of one core. Three inefficiencies were identified: a full renderer re-render every second over IPC, a helper process spawned every two seconds to read the frontmost app, and the fixed Electron baseline itself. The native port removes all three.

## Structure

- `Package.swift` at the repository root. macOS 13 or newer, Swift language mode 5.
- `Sources/TiddlyCore`: pure Foundation logic. Progression model, session clock, state store, bridge protocol model, window layout math, graph geometry. Tested with swift-testing in `Tests/TiddlyCoreTests`.
- `Sources/Tiddly`: the AppKit app. App delegate, one floating non-activating panel, custom-drawn card and pet views, drink and bubble overlay, Unix socket bridge server, artwork cropping, font registration.
- `scripts/build-app.sh`: `swift build -c release`, then assembles `dist/Tiddly.app` with the five artwork sheets and the Gaegu font, writes `Info.plist` with `LSUIElement`, and ad-hoc signs.
- Node remains only for the hook scripts. `package.json` keeps `start`, `dev`, `stop`, `test`, `make`, `build`, and the hook setup scripts, with no dependencies.

## Behaviour preserved

- Pet window 176 × 176, card window 220 × 410 sharing the pet's bottom-right corner and clamped to the work area.
- Single click toggles the card, drag moves the pet with a 4 pt threshold, right-click offers Close Pet, Escape closes the card.
- Card: four stats, Ballmer peak percentage and track, logarithmic graph with reference line and marker, next-pour countdown, wine and water buttons with hover labels, pet chooser, pause, status line, cancel request, close.
- Drink animation: random pose per character, four drink frames over 1.8 s, sprite wobble, speech bubble for 4.2 s, buttons hidden while busy.
- Sleepy owl after five counted hours. Half-hour encouragement and peak celebration messages.
- Menu bar item with Show pet, Pause or Resume, Quit.
- Sleep pauses the clock; wake restores the saved paused state. Display changes reposition an off-screen pet.
- Single instance via a lock file. SIGTERM, SIGINT, and SIGHUP quit through the normal save path.
- `pet-state.json` format and location unchanged; saved position stays in top-left screen coordinates.
- Bridge socket path, permissions, request line format, and reply words unchanged, so `hooks/ballmer-hook.mjs` is untouched.

## Efficiency design

- Foreground detection subscribes to `NSWorkspace.didActivateApplicationNotification`. No helper process, no timer.
- The card redraws only while open and only when a displayed value changes. The pet redraws only on pose change. Animation timers run for their duration and stop.
- One-second tick with 200 ms tolerance for state accounting and a state save every ten ticks.

## Launching

`open dist/Tiddly.app` detaches from the terminal through launchd, so `npm start` is the background mode. `npm run dev` runs the bundle binary attached. `npm run stop` sends SIGTERM by process name. The earlier Electron pid-file launcher is removed.

## Verification

- `swift test`: 22 tests over progression, clock, state file round-trip and migration, bridge protocol, layout, graph.
- `TIDDLY_SNAPSHOT_DIR` renders pet, card, and drink frames to PNG for visual review.
- Manual: hook round-trip over the socket, state carried over from the Electron file, idle CPU and memory sampled.
