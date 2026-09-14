# Tiddly desktop pet: product and implementation handoff

**Start here:** build a small macOS desktop companion that drinks fictional wine while the user works in Codex, shows a playful two-hour Ballmer-peak curve on hover, and connects a wine gesture to the existing Ballmer coding skill. Preserve the user's hand-drawn character and relaxed tone. Prove the desktop interactions and agent connection before investing in elaborate animation.

Finalized September 12, 2026, from the product conversation and the supplied Ballmer skill. This is a build plan, not evidence that the pet or its integrations have been implemented. The existing deliverable is the skill. No character artwork has been supplied yet.

## Navigation

| If you need… | Read… |
| --- | --- |
| The product intent and non-negotiable features | Sections 1–3 |
| Complete interaction and visual behavior | Sections 4–9 |
| Timing, graph, state, and event rules | Sections 10–12 |
| Tools, architecture, and agent adapters | Sections 13–16 |
| Build tasks, validation, and release requirements | Sections 17–21 |
| Decisions still open and a ready-to-paste agent prompt | Sections 22–23 |

## 1. Product intent

The user wants a cute creature living on the desktop: an owl or a round, slightly chubby hedgehog. It keeps the user company during coding, periodically pours itself a little wine, delivers occasional encouraging messages, and lets the user give it wine or water. The humor is that the coding agent is figuratively entering a productive “Ballmer peak.”

The product should feel like a tiny companion with a useful ritual. The main experience is the creature itself, with a compact graph and controls revealed on interaction. A persistent full-size dashboard, productivity leaderboard, or complicated management interface would change the idea.

The coding workflow is real: the existing Ballmer skill instructs an agent to research, plan, implement simply, verify, and communicate clearly. The tipsiness and coding-prowess graph are fictional. The pet must not imply that it measured model intelligence, biological alcohol concentration, or actual code quality.

Use **Ballmer** for the existing skill identifier, `$ballmer` or `/ballmer`, because that is what has already been created. “Ballmer peak” may appear in explanatory product copy. A final product name and spelling remain open; do not rename the installed skill or break command compatibility for branding polish.

## 2. Authority: what is required and what is proposed

The latest user clarification takes precedence over earlier proposals and the original spoken brief. The user later selected the feasibility discussion as context for this handoff. That discussion proposed Electron, foreground-app tracking, fictional axis labels, and a pending-next-prompt integration. Include those proposals, but do not describe untested capabilities or unspecified behavior as already approved or implemented.

Use these labels throughout implementation notes:

| Label | Meaning |
| --- | --- |
| Requirement | Explicit user request or retained feature in the selected discussion |
| Proposed default | A concrete choice supplied here to make the prototype buildable; reversible and not a claimed user decision |
| Verification gate | A capability that must work in the installed environment before it is advertised |
| Later option | Preserved possibility outside the initial release's completion criteria |

The two-hour reference milestone replaces the user's earlier three-hour thought. Do not keep three hours as the default. The user subsequently clarified that water is purely cosmetic with no skill effect, manual wine moves the graph, and the curve continues rising after two hours. These are requirements, not open choices. The original bell-curve metaphor must not override the explicitly requested upward continuation. The 15-minute pour cadence and 30-minute first congratulatory message are separate behaviors; they are not competing timer settings.

## 3. Feature contract and release scope

| ID | Feature | Required behavior | Initial scope |
| --- | --- | --- | --- |
| F01 | Desktop creature | Small floating companion above ordinary desktop windows | Core |
| F02 | Character | Owl or round hedgehog, using the user's drawings when available | One placeholder first; final choice open |
| F03 | Wine imagery | Bottle, glass, pouring and drinking | Core |
| F04 | Automatic pour | A little glass every 15 minutes of counted time | Core |
| F05 | Encouragement | First message after 30 minutes, with a light, human tone | Core |
| F06 | Progression | Gradual rise to the 0.13 reference at two hours on the automatic schedule; manual wine accelerates it; keep rising afterward | Core |
| F07 | Hover graph | XY curve and moving position marker | Core |
| F08 | 0.13 | Preserve as the fictional peak reference | Core; no real BAC claim |
| F09 | Give me wine | A button triggers a pour, advances the graph, and can arm the selected agent | Core |
| F10 | Water | Cute drinking detail only; no graph, timer, skill, or other gameplay effect | Core |
| F11 | Work tracking | Count time spent using Codex | Foreground use proposed for v1 |
| F12 | Command → pet | Invoking Ballmer signals the pet to pour | Core integration, verified per host |
| F13 | Pet → skill | Clicking wine can prepare Ballmer for the next prompt | Core integration, verified per host |
| F14 | Immediate injection | Investigate affecting the current open task immediately | Later option, not promised |
| F15 | Agent-running tracking | Distinguish agent execution from app foreground time | Later option |
| F16 | Detailed coding skill | Reuse the existing Ballmer workflow | Already authored; runtime integration remains |

Pause/resume, a way to quit, recoverable placement, keyboard access, and readable connection status are supporting usability work needed to make these features practical. Their exact layout is a proposed default.

The first meaningful prototype is an installed local desktop window with a placeholder creature, functioning pours, the graph, and a testable clock. A browser page alone is not completion. The first integrated release additionally proves both connection directions for Codex and Claude Code independently, or clearly ships one supported adapter and identifies the other as unfinished. Never present partial integration as support for both.

No account, cloud backend, social feed, public site, payment flow, streak penalties, character store, or analytics service is needed for this brief. Do not add one merely because a starter template includes it.

## 4. Experience map

### 4.1 First launch

Show the creature immediately. Use a small welcome panel anchored to it, not a full-screen tour. Explain the behavior in one sentence: “A little company while you code. I’ll pour every 15 minutes.”

Present **Start with Codex** and a secondary **Try the pet** action. “Try the pet” opens the same real pet interactions without claiming an agent connection. Demonstration progress must have a visible Demo label and separate state.

Connection setup is a short follow-on panel. State which host is being connected, what configuration will change, and what the connection enables. Request only permissions needed by the chosen implementation. Do not ask for screen recording or Accessibility access just to make the app seem integrated; first test whether app identity can be observed through a smaller native API.

When custom art is missing, use a visibly temporary, simple character. Do not generate a polished substitute that establishes a new art direction. Keep the image contract stable so the user's drawings can replace it without changing business logic.

**Acceptance:** within the initial interaction, the user sees a creature, can give it a drink, and can understand whether time tracking and agent connection are ready. No sign-in is required.

### 4.2 Ordinary coding session

The creature sits quietly near the screen edge. It occasionally blinks or breathes. At 15 counted minutes, it pours and sips without opening the graph or stealing keyboard focus. At 30 counted minutes, it performs the scheduled pour and displays one short message. These events combine into one little moment.

The graph remains available on hover or keyboard activation. The creature gradually looks slightly more relaxed or rosy as time rises. Keep expressions affectionate and subtle; avoid exaggerated impairment, frantic movement, or a joke that makes the tool feel unreliable.

On automatic progression alone, the marker reaches the fictional 0.13 reference after 120 counted minutes and the pet celebrates once. Manual wine advances the marker too, so it can reach that reference earlier. After two hours, both time and more wine continue moving the curve upward; there is no cap or descending tail. The skill remains available before and after this milestone. Time investment must not unlock model access or better instructions.

### 4.3 User invokes the coding skill

The user submits `$ballmer fix the failing test` in Codex, or `/ballmer fix the failing test` in a compatible Claude Code setup. A verified adapter recognizes actual invocation, emits a local event, and the pet pours once. The existing skill guides the work.

Do not trigger just because the phrase appears inside quoted text, a pasted document, or a discussion of the skill. Prefer host-native skill expansion events when available. If only text inspection is possible, support and document a narrow leading-command form rather than pretending to parse all possible prompts.

**Acceptance:** a real submission produces a single local animation and the intended skill is available to that task. A synthetic bridge test alone does not establish this acceptance condition.

### 4.4 User clicks Give me wine

The button responds immediately with a pouring gesture and one extra increment of graph progress, even when no agent is connected. If the selected host/session is connected, it also creates a one-shot request to use Ballmer on that session's next prompt. A short status appears: “Ballmer ready for your next prompt.” The request can be cancelled.

When the next prompt is submitted, the host hook retrieves the request and supplies the activation instruction. The status can then become “Ballmer requested for this task.” It must not become “Agent upgraded” or “Ballmer active” solely because a hook emitted bytes.

If no host is connected, wine still works as a pet interaction. Show “Wine served. Connect an agent to use Ballmer.” Avoid a modal error that makes feeding the pet feel broken.

**Acceptance:** wine is satisfying on its own; the integration state is truthful; the wrong conversation never consumes the request.

### 4.5 Water, pause, and return

Giving water triggers a small, cute water-drinking animation and nothing else. It does not change the graph, counted time, wine progress, milestone flags, ongoing character state, pending requests, agent instructions, or selected model. It does not sober the pet, reset anything, or activate a skill. A temporary sip pose is presentation only and returns to the existing pose afterward.

Pause freezes counted time and automatic pours. Feeding interactions remain available. On return from pause, sleep, or lock, do not replay a backlog of drinks. Resume from the last saved counted duration, not the elapsed wall time.

## 5. UI surfaces and hierarchy

### 5.1 Desktop pet surface

Proposed starting dimensions: approximately 128–160 logical pixels tall for the character, inside a tightly bounded transparent window. Adjust after seeing the actual illustration. Keep a comfortable drag target, but avoid an invisible rectangle large enough to obstruct coding.

Default placement: lower-right inside the display work area, offset approximately 24 logical pixels from usable edges. This is a prototype default, not a user-specified location. Remember a user-selected position and clamp it to a remaining display if a monitor disconnects.

Passive animation and automatic messages must not focus the app or bring an unrelated window forward. The user should continue typing in the editor. Clicking a control or opening settings may intentionally focus the relevant panel.

### 5.2 Hover/focus card

Place a compact card adjacent to the pet, roughly 300–340 logical pixels wide. Position above or inward from the nearest screen edge. Use one panel for the curve, current progress, actions, and minimal connection status.

Proposed structure:

```text
┌────────────────────────────────────┐
│ Ballmer             45m · 1 extra sip │
│ imaginary coding prowess           │
│                         .─────↗    │
│                   .────'           │
│            ●─────'                 │
│        .──'                        │
│  0       0.13              …       │
│        imaginary tipsiness         │
│                                    │
│ Next little pour in 15m             │
│ [ Give me wine ]  [ Water ]         │
│ Codex · selected task               │
│ Ballmer ready for your next prompt   │
│ Cancel request               Pause │
└────────────────────────────────────┘
                    [pet]
```

This is a content wireframe, not a final visual reference. The curve's marker is calculated from counted time plus accepted extra wine actions. Axis range expands as needed; 0.13 is a reference milestone, not a maximum. The text status appears only when relevant; the ordinary card should not display several inactive status lines or developer diagnostics.

Do not call an interactive card a tooltip. It contains focusable controls and must behave as a popover/panel. The pet's keyboard activation opens a pinned version with appropriate focus handling.

### 5.3 Speech bubble

Use a short bubble anchored to the character, with enough contrast against any desktop wallpaper. Keep it within the work area. Default display duration: about 4–5 seconds, longer if needed for assistive access. Dismiss without moving the mouse away from coding. Do not show a bubble on every idle animation.

Automatic 15-minute pours can be silent. The first unsolicited congratulatory bubble is at 30 minutes. A manual interaction or connection status can produce immediate feedback before then.

### 5.4 Menu bar/tray and settings

Provide reliable **Show pet**, **Pause/Resume**, **Settings**, and **Quit** access through a small native menu. “Show pet” brings an off-screen or hidden companion back without resetting progress.

Settings should fit a small normal window. Group appearance and motion, time tracking, and agent connections. An advanced diagnostic view can show versions and test results. Do not expose transport names, socket locations, hook JSON, or model-routing internals in the main feeding flow.

### 5.5 Connection panel

Show Codex and Claude Code separately. Each has a state such as Not connected, Needs setup, Ready, or Needs attention. Use the specific supported surface name: Claude Code is not the same as every Claude chat product. If more than one active coding session is eligible, let the user select a target before arming a request.

Keep installation details in this panel. A useful result is “Test passed: the pet received your command.” A second result must establish that the next-prompt request was delivered to the intended session. One test does not substitute for the other.

## 6. Motion, input, and visual polish

### 6.1 Interaction timing targets

All numbers here are tuning targets, not measured performance or user mandates.

| Interaction | Initial target | Reason |
| --- | --- | --- |
| Button pressed state | Next paint; aim below 100 ms | Immediate feedback even if connection work is pending |
| Hover open delay | 180 ms | Avoid accidental panel flashes |
| Hover close delay | 250 ms after leaving the combined region | Allow travel from pet to panel |
| Card entrance | 140–180 ms opacity plus a small translation | Gentle appearance without moving the pet |
| Pour-and-sip sequence | Approximately 1.8–2.4 seconds | Readable ritual with minimal interruption |
| Speech bubble lifetime | Approximately 4–5 seconds | Brief but readable |
| Drag threshold | Approximately 5 logical pixels | Distinguish click from movement |

Keep the card open while the pointer is over the pet, the card, or the small corridor between them. Pin it while controls have keyboard focus. Escape closes an explicitly opened card and restores focus appropriately. Do not hide the panel halfway through a click because the pet and card have separate hover handlers.

Use one authoritative interaction state for pointer and keyboard behavior. Clicking the pet can pin/unpin the card. Dragging must not count as a click. Buttons, the graph, and links must not become drag handles.

### 6.2 Pour animation choreography

Start with an anticipation motion, tip the bottle toward the glass, show a short stream and rising fill, return the bottle, then sip and settle. Keep the character's feet/baseline anchored. Do not resize the native window repeatedly during the animation.

Use shared anchor coordinates for bottle pivot, glass center, mouth, and character baseline. Preload all needed assets before the first pour. If a missing asset is detected, show the last valid pose with an actionable diagnostic in settings; do not display broken-image boxes or replace it silently with an unrelated graphic.

Use CSS transforms/opacity and small image sequences. A custom animation engine, 3D renderer, or video playback stack is unnecessary for the initial product. Keep motions deterministic enough to test. Never animate layout properties on every frame merely to tip a bottle.

### 6.3 Avoid annoying event piles

Have one current animation and at most one coalesced pending animation. Multiple events that arrive together do not create a long queue of mandatory drinking. Preserve state/counters separately from presentation. Repeated clicks during a pour can use a disabled/pressed state until the gesture completes; they must not arm multiple identical skill requests.

Prioritize direct user feedback over unsolicited celebration. If a 30-minute pour and its milestone message coincide, show one pour and one bubble. If a command and an already-armed wine action represent the same request, do not replay an extra pour when the host consumes that pending request.

### 6.4 Accessibility and low-distraction behavior

Honor reduced-motion preferences: replace tipping, bobbing, and drifting with a short pose change or fade. Keep the progress value and connection status available as text. Do not convey pending/ready/error solely with color. Use visible keyboard focus and comfortably sized controls.

The graph needs an accessible description, for example: “45 minutes counted and one extra sip; fictional tipsiness 0.065.” State the actual value and reference milestone without implying a hard two-hour finish when manual wine has advanced progress. Do not announce every marker update to a screen reader. Reserve polite announcements for direct actions and meaningful milestones.

Default sound off. Sound was not requested; omit it from v1 rather than making it a surprise. Do not add confetti, flashing, or desktop notifications for every sip. Text contrast must remain legible on dark and light wallpapers.

## 7. Art direction and asset contract

The final creature and bottle artwork will come from the user. Owl versus hedgehog is unresolved. Support either through the same asset manifest; shipping two complete selectable character sets is not a requirement until both exist.

Use transparent PNG for character/bottle/glass layers. JPEG can be accepted for reference or art that has a deliberate background, but it does not provide alpha transparency. Preserve original files. If the next agent receives local non-Markdown artwork, follow the user's MarkItDown sidecar preference first, then inspect the original visually for fidelity. Do not interpret Markdown conversion as image QA.

Ask for the smallest useful art batch when implementation reaches that dependency: neutral character, a sip pose if available, bottle, wine glass, and water vessel. Additional blink/celebration poses can follow. One static drawing can be animated through modest transforms for a prototype.

| Asset property | Contract |
| --- | --- |
| Logical canvas | Stable dimensions within a character set |
| Resolution | Prefer at least 2× intended display size |
| Character baseline | Same anchor across poses to prevent jumping |
| Transparent padding | Consistent and trimmed deliberately, not randomly |
| Bottle pivot | Manifest coordinate near the grip/rotation point |
| Glass fill region | Separate layer or mask with a defined interior |
| Mouth/drink anchor | Manifest coordinate for aligning the sip |
| Motion variants | Idle, pour, sip, celebrate; still alternatives for reduced motion |

A proposed manifest might define `characterId`, `logicalSize`, `baseline`, pose paths, and named anchors. Treat asset paths as packaged resources. Do not fetch runtime art from arbitrary URLs. Keep original art under a separate source directory from optimized app assets.

Provisional UI palette: warm neutral card, dark ink, restrained wine-red accent, and muted blue for water. Final colors should come from the supplied art. Avoid overwriting the character's personality with a generic glossy gradient interface.

## 8. Copy guide

The user's tone is casual, playful, and human. Keep the pet's voice short. The agent's work updates remain clear and professional through the existing skill. Do not make all technical output sound drunk.

| Moment | Example copy | Constraint |
| --- | --- | --- |
| 30 minutes | “Half an hour. Nice work. Tiny cheers.” | First unsolicited congratulatory message |
| Manual wine, connected | “Next task: nicely aged.” | Pair with explicit next-prompt status |
| Water | “A little sip of water.” | Purely cosmetic; no state or skill effect |
| First crossing of 0.13 | “Peak little genius. Onward?” | Once per session; manual wine may get there earlier |
| Tracking paused | “Paused. I’ll save your place.” | Must preserve counted time |
| No connection | “Wine served. Agent not connected yet.” | Feeding remains usable |
| Request delivered | “Ballmer requested for this task.” | Do not claim confirmed execution |
| Expired pending request | “That request expired. Want another pour?” | No automatic rearming |

Keep the fictional framing visible in graph labels or a short explanatory line. It does not need a repeating warning dialog. Never label 0.13 with a percent sign, BAC unit, drink recommendation, or promise of better real-world performance.

## 9. Decisions not yet made: prototype defaults

The following choices make the first version internally consistent. Keep each easy to revise after the user tries the pet.

| Question | Proposed default | Why it is provisional |
| --- | --- | --- |
| First platform | macOS first; preserve adapter boundaries for others | User is on macOS, but no cross-platform commitment was made |
| Character | Neutral placeholder until owl/hedgehog art arrives | Both were suggested, neither chosen |
| What time counts? | Codex foreground while unlocked and not explicitly paused | Directly matches “on Codex”; not a measure of keyboard activity |
| Long user inactivity | Do not subtract idle time by default | User explicitly included just being on Codex; an idle cutoff would change that |
| Extra wine increment | Each accepted manual wine action adds one 15-minute-equivalent sip | Movement is required; the exact increment is a proposed tuning value |
| Water animation timing | Brief sip and return to existing pose | No gameplay or skill effect is a confirmed requirement |
| Curve shape after two hours | Smooth continuously rising function and expanding axes | Upward continuation is required; the visual formula is a proposed implementation |
| New session | Explicit New session action resets progress, with confirmation | No daily reset or automatic expiry was agreed |
| Pending request expiry | Ten minutes from arming, with clear expiry/cancel state | Prevent a stale request applying much later |
| Closing pet window | Hide pet; menu bar remains until Quit | Practical desktop behavior to test |

Manual wine must visibly move the marker. Proposed supporting text: “Time and tiny pours move you along.” The two-hour point describes the automatic-only baseline, not a mandatory wait or maximum. Do not claim the user must code for two hours before reaching 0.13 if they have added wine. Keep actual counted minutes separate from extra-sip progress.

## 10. Timing and progression specification

### 10.1 A single source of time

The main process owns `countedMs`. Renderers show it but never create authoritative progress. Use a monotonic clock for durations. A system date change must not produce negative progress or a sudden reward.

Track intervals based on observed activity transitions. Credit a known eligible interval once, then advance its sample baseline. On sleep, lock, pause, quit, or a large unobserved sampling gap, freeze credit and establish a fresh baseline on return. Do not bridge an unknown five-minute gap by assuming Codex remained active.

Foreground detection is an observation, not a perfect audit. Prefer native activation notifications, with a modest reconciliation check, instead of high-frequency polling. Record precision expectations and test transition latency. If detection fails, show Tracking unavailable and offer an explicitly labeled manual timer; do not keep counting invisibly.

### 10.2 Milestone arithmetic

Let `T` be counted milliseconds, `P = 15 * 60 * 1000`, and `K = 120 * 60 * 1000`.

The completed automatic-pour interval is `floor(T / P)`. Compare it with the persisted last processed interval; do not depend on a timer firing exactly at 15:00. The 30-minute milestone fires once when crossing `30 * 60 * 1000`. The fictional peak/reference milestone fires once when total graph position first reaches 0.13, including extra wine. Do not trigger a second peak celebration at `K` if wine already crossed it earlier.

On a legitimate delayed sample that crosses several intervals, update the processed interval to the newest value and play at most one catch-up animation. Do not replay archived milestones after launch. The 30-minute and peak flags belong to a session and must persist with it.

Next-pour countdown derives from the next interval boundary, not from the previous animation's finish. Manual wine does not reset automatic cadence under the proposed default.

### 10.3 Graph calculation

Use a deterministic illustrative curve, not an ML model. The user's latest request requires indefinite upward continuation, so do not implement a descending bell-shaped tail or a clamp at two hours. “Peak” is the playful name of the original 0.13 reference milestone, not a mathematical maximum in this product.

The exact per-click increment was not specified. Proposed default: one accepted manual wine action adds the same progress as 15 counted minutes. Counted time remains an independent honest clock. Let `extraWineCount` count accepted extra wine actions; automatic scheduled pours are already represented by elapsed progress and must not add a second increment.

```text
automaticSipEquivalent = countedMs / (15 * 60 * 1000)
totalSipEquivalent = automaticSipEquivalent + extraWineCount
markerX = 0.13 * totalSipEquivalent / 8
curveY(x) = log1p(x / 0.13) / log(2), for x >= 0
markerY = curveY(markerX)
```

This proposed function starts at zero, passes through (0.13, 1), and keeps increasing. It has no gameplay cap. Its diminishing slope is visual tuning, not a biological or productivity model. A gentler convex or linear curve can replace it if the user prefers the look, provided wine still advances it and there is no post-two-hour decline or plateau.

| Counted time | Extra wine actions | Marker x | Curve y, illustrative | Event |
| --- | --- | --- | --- | --- |
| 0 minutes | 0 | 0.00000 | 0.000 | Start |
| 15 minutes | 0 | 0.01625 | About 0.170 | First automatic pour |
| 30 minutes | 0 | 0.03250 | About 0.322 | First encouragement |
| 45 minutes | 1 | 0.06500 | About 0.585 | Manual wine accelerated progress |
| 60 minutes | 0 | 0.06500 | About 0.585 | Automatic-only midpoint in x |
| 60 minutes | 4 | 0.13000 | 1.000 | Reference reached early through extra wine |
| 120 minutes | 0 | 0.13000 | 1.000 | Automatic-only reference arrival |
| 150 minutes | 0 | 0.16250 | About 1.170 | Still rising |
| 150 minutes | 1 | 0.17875 | About 1.248 | Another wine moves farther up and right |

Interpolate a manual marker transition over roughly 200–350 ms; commit its logical progress immediately and animate only the view. A second accepted pour adds another increment even if a skill request is already pending. While an actual pour animation is busy, make the button's temporary disabled state clear rather than silently accepting and dropping clicks.

Grow the visible axes in stable steps when the marker approaches the edge. Preserve the labeled 0.13 reference and show the current numeric x value so rescaling does not look like lost progress. Do not shrink the domain on water, panel reopen, or rerender. Animate a domain expansion smoothly; store the session display extent or derive a monotonic extent from progress. Avoid a fixed 0–100% progress bar or a `45 / 120m` label that implies completion is capped.

Celebrate the first crossing of x = 0.13 once, including a crossing caused by manual wine. The 30-minute encouragement is still tied to actual counted time. Additional celebrations beyond the reference are not required; pours and upward motion continue. A directly typed skill invocation is proposed to count as one extra wine action, while delivery of an already-credited manual-click request must count as zero extra actions.

The user described 0.13 as a reference, not a settled editable dose menu. Show it as a milestone label in v1. Do not invent real-world alcohol units or a preset dose selector.

### 10.4 Persistence and resets

Persist counted duration, accepted extra-wine count, session ID, processed pour interval, milestone flags, pet placement, appearance preferences, and tracked app selection. Save at meaningful transitions and on a modest periodic checkpoint; do not write state every animation frame. Proposed checkpoint interval: 10 seconds, with an explicit maximum progress-loss bound on abrupt termination.

Use a versioned state schema and atomic replacement for ordinary settings/state. Preserve an unreadable file for diagnosis; do not silently wipe it. Pending activation requests are short-lived process/session state and should be invalidated across pet restarts in v1 unless a later durable protocol is designed and tested.

New session resets the timer, extra-wine progress, graph, and milestone flags together after confirmation. It does not uninstall the skill or change the agent's model. App restart resumes saved duration; offline time is never credited.

## 11. State model

Keep orthogonal facts separate. A creature can be drinking while time tracking is paused and the bridge is disconnected. One giant enum would create unnecessary combinations.

| State group | Suggested values/data | Owner |
| --- | --- | --- |
| Tracking | running, paused, unavailable; current eligibility | Main process |
| Progress | session ID, countedMs, extraWineCount, processed interval, milestone flags | Main process |
| Presentation | idle, pouring-wine, sipping-water, celebrating; current event ID | Renderer animation coordinator |
| Panel | closed, hover-open, pinned; focus ownership | Renderer |
| Connection | per-provider setup/readiness and last verified contact | Main process adapter |
| Activation | none, pending, delivered, expired, cancelled; target and request ID | Main process bridge |

“Delivered” means the helper returned an activation request to a host hook. It does not prove the host accepted it, the model read the skill, or the task obeyed it. If a later adapter exposes acknowledgment, add that distinct evidence without retroactively changing the meaning of delivered.

For domain choices that genuinely have two states, use direct booleans/predicates. Multi-state integration status is legitimate; do not force it into a misleading boolean merely because the coding skill favors simple logic.

## 12. Event contract and race behavior

Use typed local messages, with a protocol version, stable event/request identity, and bounded payload size. Prefer a small discriminated union with a few real commands over a generic command execution endpoint.

Proposed event families:

| Event | Minimum useful data | Effect |
| --- | --- | --- |
| Activity changed | app identity, monotonic observation time, eligibility | Close/open counted intervals |
| Give wine | UI event ID, selected target if any | Advance graph once, animate once, optionally arm |
| Give water | UI event ID | Presentation only; change no progress or activation state |
| Skill invoked | provider, session identity, host event identity when available | Animate; proposed default grants one extra wine increment unless already credited to the originating click |
| Take pending request | provider, session identity, hook invocation identity | Atomically retrieve eligible activation |
| Cancel pending | request ID | Remove only that request |
| Test connection | provider and test nonce | Report connection evidence; never pretend it is real skill activation |

A request stores `requestId`, `provider`, a local installation identity, `sessionId`, creation time, expiry time, and the installed skill reference/version. Do not broadcast a global “next prompt” flag across all sessions or merge identically named sessions from different installations.

Define target selection before arming. With exactly one eligible known session, show that target. With several, require an explicit choice in the small connection selector. With none, feeding still works and setup remains available. Do not guess by whichever hook races first.

Build the session registry from verified lifecycle hooks such as session start/end and refresh it on submissions. Store provider/session identity, a minimal local workspace label where available, and last-contact time; do not invent a conversation title that the host never supplied. Clear ended sessions and their pending requests. After a pet restart, require sessions to register again before targeting them. If the installed host cannot expose reliable session identity, pet-to-next-prompt targeting remains unavailable on that surface; command-to-pet animation can still work separately.

Repeated accepted wine clicks advance the graph each time, but maintain only one pending activation for the selected session. Reaffirm the existing request rather than queuing several future prompts. Proposed default: do not extend its expiry unless the user explicitly rearms after cancel/expiry; show the real pending state. A timed automatic pour never creates an activation request. Water never contacts a host adapter.

Concurrent takes must not both claim the same pending request. The Electron main process can serialize claims while it is the single bridge owner. Make transport retries idempotent for the same hook invocation; bounded cached responses should survive duplicate transport messages within the process lifetime. On a process crash, report the request as lost/unknown on return rather than promise exactly-once cross-process delivery.

If the bridge cannot tell whether a delivery response reached the host, report Delivery uncertain and require a deliberate rearm rather than silently applying the request to a later prompt. Distinguish this case from a definite connection failure before a claim was made.

Native skill invocation should not additionally inject the same skill text. Credit wine progress once per logical pour, not once per animation frame, hook event, and acknowledgment. If a native invocation consumes a matching pending request, acknowledge that request and coalesce the presentation event. Events require identity, not just a time-based suppression window: two deliberate invocations may happen close together.

If a provider cannot supply a stable host event ID, generate a per-helper invocation ID for transport deduplication and document its limits. A hash of prompt text is not sufficient because identical legitimate prompts can occur twice. Never persist prompt text merely to deduplicate an animation.

## 13. Recommended tools and architecture

### 13.1 Stack

Use Electron with TypeScript for the native shell and bridge. React is a proposed renderer choice for the small interactive card and settings; plain TypeScript is acceptable if it is clearer in an existing project. Use CSS and inline SVG for motion and the graph. Do not use JAX for this desktop UI: the skill's JAX requirement concerns numerical research code.

Electron supports the required window interactions, but transparency does not automatically make empty pixels click-through. Drag regions also suppress pointer events within them. Prove both behaviors in the actual macOS build. [Electron custom window interactions](https://www.electronjs.org/docs/latest/tutorial/custom-window-interactions)

Use Electron Forge for development/package tooling, selecting compatible pinned versions after a clean scaffold succeeds. Its templates include a Vite route and a TypeScript variant. Avoid copying a guessed dependency matrix. [Forge getting started](https://www.electronforge.io/), [Vite template](https://www.electronforge.io/templates/vite)

| Layer | Proposed tool | Why |
| --- | --- | --- |
| Desktop shell | Electron, TypeScript | Native windows, lifecycle, local bridge |
| UI | React, CSS, SVG | Small composable views and inspectable animation |
| Build/package | Electron Forge with a verified template | Development and macOS artifacts |
| Pure-logic tests | Existing runner or Vitest | Fake clocks and deterministic event checks |
| Renderer/Electron smoke tests | Playwright Electron | Scripted interaction and screenshots; support is experimental |
| Native macOS activity helper | Small Swift/AppKit helper if needed | Observe frontmost app identity without scraping chat content |
| Art preparation | User PNG/JPEG originals; format-specific inspection | Preserve authored appearance |

Playwright can launch and inspect Electron applications, but native focus, Spaces, click-through, and display behavior still require real desktop testing. Browser snapshots do not prove those OS behaviors. [Playwright Electron API](https://playwright.dev/docs/api/class-electron)

### 13.2 Process separation

```text
macOS app activation / lock / sleep
                 |
                 v
Electron main: activity + timer + state + local bridge
            |                          ^
     narrow typed IPC                  | local socket
            v                          |
renderer: pet + graph + controls   host hook helper
                                       |
                              Codex / Claude Code
                                       |
                              existing Ballmer skill
```

The renderer does not read host configuration, spawn arbitrary commands, or receive raw prompt text. The main process exposes narrowly defined pet actions and read-only state snapshots through a preload bridge.

### 13.3 Practical module boundaries

The following paths are proposed relative paths inside the future product repository, not files that already exist:

```text
src/
  main/
    app.ts
    windows.ts
    activity.ts
    session-clock.ts
    state-store.ts
    bridge.ts
    adapters/
      codex.ts
      claude-code.ts
  preload/
    index.ts
  renderer/
    Pet.tsx
    PetPanel.tsx
    PeakGraph.tsx
    SpeechBubble.tsx
    Settings.tsx
    animation.ts
    styles.css
  shared/
    protocol.ts
    progression.ts
    assets.ts
native/macos/
hooks/
assets/
tests/
```

Use classes for meaningful stateful responsibilities such as a session clock, bridge, or window coordinator. Keep graph arithmetic and event transformations pure. Start with these conceptual responsibilities, not empty files for every name. Avoid a general plugin framework or dependency-injection container.

### 13.4 Window strategy

Prototype a tight pet window plus an anchored card window, or a single tightly managed window that expands while preserving the pet anchor. Choose after testing hover transit, keyboard focus, click-through, and edge placement. The visible creature must not jump when the card opens.

If using native drag regions, keep them separate from interactive controls. If manual pointer dragging is clearer for the character, implement a click/drag threshold and coordinate conversion through the main process. Test Retina scaling, negative monitor coordinates, display disconnect, Dock movement, and screen-edge clamping.

Use a nonintrusive always-on-top level suitable for ordinary app windows. Do not claim the pet can or should cover secure system UI. Full-screen/Spaces behavior is a verification gate; document the supported result and avoid repeated focus manipulation to force it.

### 13.5 Tracking adapter

Electron's power monitor provides suspend/resume and lock/unlock observations useful for pausing credit. It is not a Codex activity detector. [Electron powerMonitor](https://www.electronjs.org/docs/latest/api/power-monitor)

Evaluate AppKit's frontmost-application API and activation notifications in a small native helper. The Apple API is an implementation lead, not a tested permission claim in this project. Read the current documentation and test the signed build. [Apple frontmostApplication](https://developer.apple.com/documentation/appkit/nsworkspace/frontmostapplication)

Observe verified application identities rather than hard-coded process display strings guessed from memory. A terminal in the foreground does not establish that Claude Code is active inside it. Do not count all Terminal time as Claude work. Agent-session activity tracking requires a separate definition and adapter, not a relabeling of foreground detection.

## 14. Codex and Claude Code connection design

### 14.1 Existing skill is the content owner

The authored skill is at [../ballmer/SKILL.md](../ballmer/SKILL.md), with [source notes](../ballmer/references/sources.md) and [Codex UI metadata](../ballmer/agents/openai.yaml). A user may install it under their own Codex skills directory. Use repository/package-relative paths in the app; do not hard-code a user's home directory into distributed code.

Reuse the full skill and its references. Do not replace it with a generic sentence such as “write better code.” It includes JAX research discipline, actual model routing for cheaper subagents when supported, no new catch scaffolding, mathematical comments, measured optimization, three-failure reassessment, and concise updates.

Package one canonical skill source and copy/install it per supported provider using the provider's documented discovery location. Track a content hash/version so settings can distinguish installed from current. Do not silently overwrite a user-edited skill; offer the concrete diff/update choice in connection setup.

### 14.2 Capability gate for each host

Before implementing an adapter, record the installed app/CLI version and the specific host surface. Inspect current official documentation and available configuration. Test in a disposable project/session before updating personal hooks.

For Codex, the current manual documents explicit `$skill` invocation and `UserPromptSubmit` with prompt/turn data and an additional-context response. Matching behavior and payload limits matter. [Codex skills](https://learn.chatgpt.com/docs/build-skills), [Codex hooks](https://learn.chatgpt.com/docs/hooks)

For Claude Code, skills can expose `/skill-name`; current hook documentation also describes skill/command expansion events. Prefer an exact expansion event when present in the installed version. Otherwise use a documented submit hook with conservative detection. [Claude Code skills](https://code.claude.com/docs/en/skills), [Claude Code hooks](https://code.claude.com/docs/en/hooks)

The existence of documentation is not a passing integration test. Preserve a versioned test record for command observation, skill activation, session identity, and failure behavior. Do not infer that desktop, terminal, browser, and remote sessions expose identical hooks.

### 14.3 Agent → pet

1. User invokes the real installed Ballmer skill in a supported session.
2. The host hook adapter identifies invocation using verified host event semantics.
3. A local helper emits a bounded `skill-invoked` event with session/event identity, excluding the raw prompt.
4. The main process validates/deduplicates the event and updates UI state.
5. The renderer plays one pour without changing actual counted time or interrupting coding focus. Proposed default: a directly typed command contributes one extra sip, like manually feeding wine; delivery of an already-credited click contributes none.

The animation must not rely solely on the language model remembering to call a decorative tool. The hook handles the deterministic local event. When the pet is closed, the host still runs the skill normally; do not launch a swarm of new background pet instances.

### 14.4 Pet → next prompt

The initial supported direction is **prepare the next prompt in a selected session**. This preserves the user's one-click idea while avoiding unverified control of the current desktop composer.

1. Wine click produces immediate visual feedback, credits one extra sip, and asks the main process to arm the selected target. The sip succeeds independently of bridge availability.
2. The main process records one pending request and returns success or a specific unavailable status.
3. On that session's next eligible user submission, a hook atomically takes the request.
4. The helper returns a provider-valid instruction to load/use the trusted installed Ballmer skill for the submitted task.
5. The UI reports delivery evidence and clears the pending request without asserting successful task execution.

Do not inject a several-thousand-word skill blindly into hook context. The host may truncate or spill large hook output. Prefer a concise activation instruction referencing the trusted installed skill path, then verify that the agent actually loads it. A literal `$ballmer` inside hook-added context is not automatically proven to trigger the native skill loader. Test that behavior, or use a supported attachment/invocation mechanism. Keep the full skill available locally and fail the activation smoke test if it only receives a summary.

Retain the user's actual task and its priority. The bridge must not substitute a new coding task, change the selected model, or introduce standing permission to modify unrelated files. Disable activation when the target cannot be identified rather than send instructions to an arbitrary conversation.

### 14.5 Bridge transport and helper lifecycle

Proposed macOS transport: a Unix-domain socket owned by the pet's main process in a private per-user runtime directory. Restrict directory/socket access to the user and validate message schema/size. This is a modest local IPC bridge, not an internet server. If another platform requires a different transport, implement a named pipe or an authenticated loopback equivalent there.

Use one small helper executable available to the hook environment. Do not assume a GUI application's bundled Node is discoverable on a user's shell PATH. Test installed paths containing spaces and non-ASCII characters, and package the helper for the intended architecture.

A broken pet bridge must not block ordinary coding. Proposed local request budget: 250 ms, measured and tuned in the real host. When the optional bridge is unavailable, emit a host-valid nonblocking result and a local diagnostic; do not swallow errors invisibly or retry indefinitely. The UI can later report that the activation was not delivered.

Honor the user's no-try/catch preference in new application code. Use explicit validation and documented result/error channels for expected bridge outcomes; do not disguise blanket catching as a helper called `ensureConnected`. If a chosen library genuinely requires a catch to implement an essential interface, name that exact conflict and resolve it rather than silently violating the preference. This does not mean crashing the agent workflow when a decorative pet is offline.

### 14.6 Hook installation and removal

Read existing user/project hook configuration before editing. Show exactly which Ballmer-owned entries will be added and save a recoverable copy of the original configuration. Preserve all unrelated hooks, ordering requirements, comments where the format permits, and host trust requirements. Use stable ownership markers or a manifest for later updates/removal. Do not replace an entire hooks file with a generated minimal example.

If a runtime requires the user to review/trust a hook, surface that concrete step during setup. Do not ask repeatedly after the authorization already covers the action. A hook that exists on disk but is not trusted/running is not Ready.

Removal deletes only Ballmer-owned entries and helper artifacts. Keep user progress/character preferences unless the user explicitly chooses to remove them. Test setup twice, update once, and remove once without damaging a fixture containing unrelated hooks.

### 14.7 Immediate current-task injection remains a separate experiment

The user asked whether clicking the pet can inject a prompt directly. Preserve this ambition, but do not make the initial next-prompt design pretend to do it. A click cannot retroactively change a prompt that has already been processed.

Codex App Server supports building clients and sending/steering turns, but that alone does not establish authorization or access to the currently selected desktop task. [Codex App Server](https://learn.chatgpt.com/docs/app-server)

Before enabling an immediate mode, prove access to the intended task, user intent, idle-versus-running behavior, interruption/steering semantics, response acknowledgment, and a clean failure path. Avoid brittle automated typing into a focused window as the default product architecture. If the public integration surface cannot target the existing task reliably, keep the supported next-prompt mode and document the limitation.

## 15. Local data, permissions, and reliability

Keep ordinary pet state local. The timer and graph need app identity and elapsed duration, not screenshots, keystrokes, clipboard monitoring, repository content, or full prompts. Hooks may receive prompt data from the host; inspect only what the adapter needs and do not store/transmit the body to the pet.

Use Electron isolation and a small preload API; do not enable Node integration in the renderer or load arbitrary remote pages there. Validate IPC sender and payloads, restrict navigation, and use a content security policy suited to packaged assets. These are implementation requirements for this native architecture, not onboarding material. [Electron security guidance](https://www.electronjs.org/docs/latest/tutorial/security)

Enforce a single app instance and a single bridge owner. Handle display and lifecycle events deliberately. Preserve corrupt state for diagnosis; give a clear recovery action instead of an invisible reset. Keep diagnostic logs bounded and exclude prompt text, tokens, and secrets.

The pet should not keep the machine awake or run continuous high-frequency CPU loops. Render motion only when needed, stop animation while hidden, and measure an idle build on the target machine. Proposed initial idle CPU target: below 1% on the test machine, with hardware and measurement method recorded; revise from evidence rather than claim universal performance. Report memory footprint and regressions rather than invent a size guarantee before building Electron.

## 16. Development workflow for the next agent

Read the existing Ballmer skill and use it for the build. Lead-agent planning and hard integration decisions stay with the higher-capability configured model. Assign bounded UI or clock implementation and an independent review to available cheaper models when the runtime supports actual selection. Do not change models merely through prose or fabricate cost savings.

Keep one owner for shared event types and persisted schemas. UI work can proceed with fixture events while the lead tests the native bridge. Do not let two agents edit the same hook installer or state machine concurrently.

Every delegated implementation task should contain the relevant feature IDs, permitted files, acceptance condition, fixture inputs, and expected return evidence. A reviewer should inspect the actual diff and behavior. Neither “the child says done” nor a pleasing screenshot proves native focus or hook behavior.

Record short progress updates approximately every 30–60 seconds during active work when tooling permits. Report the step completed, the blocking observation if any, and the next action. After three failed fixes to the same issue, stop patching and reassess the assumption. Do not keep rewriting the UI to compensate for an untested native-window limitation.

## 17. Five-stage implementation plan

Each stage has a demonstrable exit condition. Estimates are provisional hands-on engineering time for one experienced implementer, excluding drawing, account setup, and unpredictable platform/debugging delays. They are planning ranges, not completion promises. Re-estimate after Stage 1 proves the desktop and host capabilities.

### Stage 1 — Prove the native shell and connection surfaces

**Planning estimate: 4–8 hours.** This stage reduces the highest uncertainty first.

1. Inspect the workspace, instructions, package manager, native build tools, and installed Codex/Claude Code versions. Save a small capability record with exact versions and supported surfaces.
2. Scaffold a minimal Electron/TypeScript app in the chosen product repository. Launch a transparent placeholder pet with a quit menu and demonstrate that passive display does not steal typing focus.
3. Prove dragging, click-through outside intended hit regions, hover-to-panel travel, and placement on the actual monitor layout. Choose the window strategy from this evidence.
4. Test a read-only foreground-app helper and sleep/lock observations. Separate app-presence, foreground, and agent-running semantics. Do not guess package permission requirements.
5. In disposable host configurations, prove a command hook can emit a local test event and the host can load the installed skill from a next-prompt activation instruction. Record failures separately for each provider.

**Exit:** the pet can sit on the desktop without breaking interaction, and the next agent knows which integrations work in the installed environment. Missing final artwork does not block this stage. A missing second provider must remain an explicit integration gap, not disappear from the plan.

### Stage 2 — Build deterministic pet behavior and the graph

**Planning estimate: 6–10 hours.** Implement against a fake clock before waiting for real milestones.

1. Define progress/state/event types and pure graph calculations. Test time boundaries, manual-wine increments, upward continuation, cosmetic-only water, and repeated event handling.
2. Build the authoritative main-process session clock, explicit pause/resume, sleep/lock handling, restart persistence, and no-offline-credit rule.
3. Create the pet view, hover/focus card, SVG curve, textual progress, wine and water buttons, and a basic speech bubble using placeholder assets.
4. Add a single animation coordinator with event coalescing, manual click feedback, reduced-motion behavior, and anchored transitions.
5. Run an accelerated demonstration with isolated Demo state, then a real-clock smoke check. Verify that timer updates do not re-render or reposition every native window unnecessarily.

**Exit:** every core pet interaction works without any agent installed. Demo time cannot contaminate real progress, and a restart does not award missed pours.

### Stage 3 — Connect real agent sessions in both directions

**Planning estimate: 8–16 hours, revised from Stage 1.** Host version differences may dominate this work.

1. Implement the private bridge and packaged hook helper with bounded typed messages, request identity, session identity, and a nonblocking unavailable result.
2. Build idempotent, provider-specific hook setup/update/removal that preserves unrelated configuration and respects required trust steps.
3. Implement exact/conservative native skill-invocation detection and prove one pour for one real invocation, including quoted-text negatives and transport duplicates.
4. Implement selected-session arming, one-shot retrieval, expiry/cancel, request-status copy, and duplicate suppression when native invocation and pending activation coincide.
5. Run real Codex and Claude Code task smoke tests independently. Verify skill loading, wrong-session rejection, bridge-offline behavior, and absence of raw prompts in persisted pet data.

**Exit:** command-to-pet and pet-to-next-prompt behavior are demonstrated on each claimed supported provider. Immediate steering of an existing desktop task is not required for this stage and must not be implied by its UI.

### Stage 4 — Integrate user art and polish desktop UX

**Planning estimate: 6–12 hours after usable art arrives.** Continue with placeholders on independent work if art is pending.

1. Preserve/inspect supplied drawings, define the asset manifest, and align pose baselines and bottle/glass/mouth anchors. Confirm owl versus hedgehog before declaring final art complete.
2. Tune pour timing, gentle idle expression, the 30-minute message, and first-crossing reference celebration, which occurs at two hours only on the automatic-only schedule. Check a frame at each animation transition for jumps or blank assets.
3. Refine panel placement, hover retention, click/drag distinction, keyboard focus, reduced motion, text contrast, and muted styling around the actual drawings.
4. Test multiple displays, Dock positions, display removal, Spaces/full-screen behavior, sleep/lock, and continued typing during unsolicited animation. Fix native behavior rather than covering it with extra UI.
5. Measure idle CPU, startup responsiveness, animation smoothness, and bridge latency on the target Mac. Record observations and revise targets if needed.

**Exit:** the companion feels quiet and responsive, stays out of the user's typing path, and accurately communicates progress and connection state. Do not call the art final if only a placeholder exists.

### Stage 5 — Package, verify, and hand over

**Planning estimate: 4–8 hours, excluding signing account/certificate availability.**

1. Build a local macOS artifact through the chosen Forge configuration. Verify helper/asset paths from the packaged app, not only the development server.
2. Test clean setup, relaunch, state restore, update, and removal against existing user-style hook fixtures. Confirm that closing/hiding differs from Quit as documented.
3. Run the acceptance matrix in Section 18 and record pass/fail/unverified with evidence. Resolve blockers for every capability advertised in the UI.
4. For external distribution, configure signing/notarization with already-authorized credentials and the documented process. If credentials are unavailable, deliver a local build labeled accordingly; do not claim a signed release.
5. Deliver the app artifact, reproducible build instructions, known limitations, evidence record, and the small remaining decisions. Investigate immediate current-task injection only as a separately scoped extension once the core works.

**Exit:** a next agent or the user can install and exercise the documented product without reconstructing this conversation. Packaging does not authorize publishing to an app store or external site.

## 18. Acceptance matrix

Use this as a behavior checklist, not merely a count of test files. Automated tests, actual host tests, and manual native checks have different evidentiary value.

| ID | Scenario | Expected result | Best verification |
| --- | --- | --- | --- |
| A01 | Launch with no artwork supplied | Clearly temporary pet works; missing art is documented | Desktop smoke |
| A02 | Keep typing during auto pour | Editor retains focus and characters | Native manual check |
| A03 | Click beyond pet's intended hit area | Underlying app receives click | Native manual check |
| A04 | Drag then release pet | Position changes; no accidental wine/card click | Native + UI test |
| A05 | Move pointer from pet to card | Card stays open; controls work | UI + native check |
| A06 | Open card with keyboard | Focus visible; actions reachable; Escape behaves correctly | Keyboard check |
| A07 | Cross 15-minute boundary | Exactly one logical auto-pour interval processed | Fake clock |
| A08 | Cross 30-minute boundary | One pour and first encouragement, not two animations | Fake clock + UI |
| A09 | Reach 120 minutes with no extra wine | Marker at 0.13; reference celebration once | Logic + UI |
| A10 | Run and drink past two hours | x and y keep increasing; axes accommodate values; no cap or decline | Fake clock + UI |
| A11 | Give wine at 37 minutes | Immediate gesture and graph increment; actual minutes unchanged; one pending request if connected | UI + bridge |
| A12 | Give water while request pending | Animation only; all progress, skill, request, and persistent state unchanged | State test |
| A13 | Pause, lock, sleep, or quit | Ineligible time does not count | Clock + native |
| A14 | Restart after 30-minute milestone | Restore duration; no replayed congratulation | Persistence test |
| A15 | System clock moves backward/forward | No negative duration or bonus progress | Clock test |
| A16 | Long unobserved sampling gap | No invented foreground credit | Clock test |
| A17 | Disconnect monitor holding pet | Pet returns to a valid work area | Native manual check |
| A18 | Reduced motion enabled | Actions and graph still understandable without moving gestures | UI check |
| A19 | Real Codex `$ballmer` invocation | Skill loads; one pet pour | Real host smoke |
| A20 | Real Claude Code `/ballmer` invocation | Skill loads; one pet pour | Real host smoke |
| A21 | Prompt merely quotes the command | No false invocation animation | Adapter fixture + real host |
| A22 | Wine arms selected session | Only that session can take the request | Concurrent bridge test |
| A23 | Two simultaneous eligible submissions | One claim; retries for same invocation are idempotent | Concurrency test |
| A24 | Same text submitted deliberately twice | Two legitimate invocations remain distinguishable | Adapter test |
| A25 | Pending request plus native invocation | No duplicate instructions, graph credit, or second pour for the same gesture | Integration test |
| A26 | Request expires or is cancelled | Later prompt does not consume it | Fake clock + bridge |
| A27 | Pet offline/helper connection fails | Normal coding continues; no false delivered status | Real host failure test |
| A28 | Hook installed but not trusted | UI does not show verified Ready | Host setup check |
| A29 | Unrelated hooks already configured | Setup/update/remove preserves them | Config fixtures |
| A30 | Target task cannot be identified | No global request races into a random task | Integration test |
| A31 | Hook adds only an activation reference | Actual skill loading verified; not assumed from syntax | Real host content check |
| A32 | Packaged app path has spaces | Assets and helper work | Packaged smoke |
| A33 | Inspect local state/logs | No raw prompts, credentials, or unnecessary content | File inspection |
| A34 | New session action | Confirmed reset of timer/marker/milestone flags only | UI/state test |
| A35 | Demo run then normal launch | Real progress unaffected | State isolation test |
| A36 | Extra wine reaches 0.13 before two hours | Celebrate once; actual time remains accurate; no repeat at 120 minutes | Logic + UI |
| A37 | Give several wines while one activation is pending | Each accepted wine advances graph; only one activation remains pending | State + bridge |
| A38 | Wine while disconnected or time paused | Wine advances graph; no time credit or false skill-delivery claim | State + UI |
| A39 | Water repeated before/after peak | No graph, timer, skill, sober-state, or persistent counter effect | State test |
| A40 | Axis expands at high progress | Marker stays visible; no apparent loss of accumulated value | UI test |

## 19. Development commands and evidence record

The future repository should expose a small set of clear scripts. These are target script names to create and verify, not commands already available in this handoff directory:

| Script | Expected purpose |
| --- | --- |
| `npm run start` | Launch the real desktop app for development |
| `npm run typecheck` | Check TypeScript contracts |
| `npm test` | Deterministic clock/state/adapter unit checks |
| `npm run test:desktop` | Electron smoke tests where supported |
| `npm run make` | Produce the local packaged app artifact |

Use the package manager already chosen by an existing repository; do not add a competing lockfile. A documentation preview is not the app. A headless Linux CI test is not proof of macOS focus behavior.

Maintain a compact validation record with build revision, OS/hardware, dependency and host versions, test command/result, manual native observations, and any unverified adapter behavior. For integration fixtures, redact/avoid prompt content and use harmless test tasks.

Performance evidence should include idle CPU measurement duration, app memory, animation observations, and bridge response latency. Do not report averages without noting the workload or hide first-launch/packaged-path failures behind a warmed-up development run.

## 20. Delivery and distribution

For local use, deliver a packaged macOS app and simple installation instructions appropriate to its signing state. For broader distribution, signing and notarization are separate work that require the appropriate credentials/tooling. Use the current Forge guidance and verify the resulting artifact. [Forge macOS signing](https://www.electronforge.io/guides/code-signing/code-signing-macos)

Do not start with Mac App Store distribution unless explicitly selected. It adds a different packaging/sandbox context that may affect local integrations. A website and online installer service are not required to satisfy the current product brief.

The final handover should distinguish: implemented pet behavior, tested host adapters, provisional UX decisions, missing user art, and experimental future integrations. No vague “everything works” statement should hide an untested Claude adapter or a missing direct-injection path.

## 21. What exists now

| Artifact | Status |
| --- | --- |
| [Ballmer SKILL.md](../ballmer/SKILL.md) | Authored and structurally validated; installed in this user's Codex skills folder |
| [Skill source notes](../ballmer/references/sources.md) | Source provenance for coding workflow |
| [Codex skill UI metadata](../ballmer/agents/openai.yaml) | Authored |
| This product handoff | Planning artifact |
| Desktop application | Not implemented in this handoff task |
| Pet/bottle drawings | Not yet supplied |
| Native timer/activity tracking | Not implemented/tested |
| Codex/Claude pet adapters | Not implemented/tested |
| Immediate current-task injection | Feasibility remains to be established |

A newly visible `$ballmer` skill is not the desktop pet. It does not itself install hooks, watch time, draw a creature, or connect to an arbitrary conversation. Preserve that boundary when explaining progress.

## 22. Open decisions and when to ask

Proceed with reversible defaults and ask only when the answer blocks dependent work. Do not repeat all of these questions at the start.

| Decision | Ask at… | Default for independent progress |
| --- | --- | --- |
| Owl or hedgehog, and final art | Before final asset integration | Neutral placeholder using the same manifest |
| Size of a manual-wine increment | During interaction tuning, only if the proposed amount feels wrong | One 15-minute-equivalent sip; movement itself is required |
| Direct skill-command wine also adds an extra sip? | Before final command-to-pet tuning | Yes for a new command gesture; never double-credit a pending-click delivery |
| Session reset policy | Before final timer UX approval | Explicit confirmed reset; ongoing curve rises without a cap |
| Which host surface/version is the first supported target? | During capability inspection if not discoverable | Codex on the current Mac first; track Claude separately |

Additional capability questions, such as immediate task steering or a remote agent connection, should arise from concrete evidence. Do not hold up the local pet while waiting for a future integration that is not required for its standalone experience.

## 23. Prompt for the next agent

Copy the following into the next agent together with this handoff and the Ballmer skill folder:

> Build the Tiddly desktop pet described in BALLMER-PRODUCT-HANDOFF.md. Read that document and the supplied ballmer/SKILL.md first. Preserve the user's features: a hand-drawn owl or round hedgehog, fictional wine/water interactions, 15-minute automatic pours, first encouragement at 30 minutes, a hover curve reaching the fictional 0.13 reference after two hours on automatic progression alone, manual wine advancing the graph, purely cosmetic water with no skill effect, a curve that continues rising after two hours, and both native skill-command-to-pet and pet-to-next-prompt connections. Use the proposed defaults only where the document labels them as such. Start with Stage 1: inspect the actual environment and prove native window behavior and host integration capabilities. Build a real local desktop app, not just a browser mockup. Use placeholder art until the user's drawings arrive. Keep the lead model on planning and difficult integration work; delegate bounded implementation and independent critique to supported cheaper models. Work through the staged acceptance conditions, give concise periodic updates, and report evidence. Do not claim direct control of an existing desktop task, successful skill loading, or support for a provider until it has been tested. Continue authorized implementation without ceremonial approval pauses; ask only for a necessary unresolved choice or destructive/external action.

**First bounded action:** inspect the existing workspace and installed host versions, then create the Stage 1 capability record before scaffolding the desktop app.
