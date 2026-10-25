## Decision / Outcome (2026-10-25)

Implemented on `chore/finish-audit-changes` (commits `f0e1ec8..HEAD`). The suite went from 126 tests
(8.7 s) to 267 (~5 s locally, maintainer-reported). CI has not yet run on GitHub.

**Time control — one mechanism per seam:**

| Seam | Mechanism | Where |
|------|-----------|-------|
| `GameNotifier` countdown, 1 s ticker, 500 ms error flash | `fakeAsync` + `async.elapse` | `test/game/game_notifier_test.dart` |
| `PinLockout` attempt limit and 30 s lockout | injected clock: `PinLockout(box, now: () => ...)` | `lib/features/parent/providers/pin_lockout.dart`, `test/parent/pin_lockout_test.dart` |
| Reminder scheduling | injected `now` on pure `NotificationService.planReminder(...)` | `lib/shared/services/notification_service.dart`, `test/services/reminder_plan_test.dart` |
| Session timestamp | optional `playedAt` on `buildSessionFrom` | `test/game/ordinal_tap_test.dart` |

**Refactors made for testability** (each kept to a seam; the game loop itself was not restructured):

- `processOrdinalTap` — pure tap rule shared by classic, reverse and letters (validates the cell's
  ordinal against `nextNumber`; only the label differs). Replaces private `GameNotifier` methods.
- `coinsForSession`, `buildSessionFrom` — pure, read the constants instead of hard-coded values.
- `SessionCompleter` (`features/game/providers/session_completion_provider.dart`) — record, session,
  streak, coins, XP, character unlocks, achievements, Game Center and reminder, moved out of the
  `GameScreen` widget so the whole chain runs in a `ProviderContainer`. The reminder call is
  injectable so tests avoid the notification plugin.
- `achievementsToUnlock` — pure unlock rules; `checkAchievements` now takes a plain `Ref` and only
  persists what the rules return.
- `NotificationService.planReminder` (+ `hasPlayedOn`, `variantIndexFor`) — pure decision split from
  `rescheduleFromStorage`, which keeps the Hive reads and platform calls.
- `PinLockout` — attempt count and lockout deadline persisted in Hive (survives screen re-entry and
  restart), clock injectable. `ParentPinScreen` delegates to it.
- `GameNotifier` cancels its timers in `ref.onDispose`.

**Revised decision.** The original plan said "test the notifier, not just the pure functions". What
shipped is more pure extraction plus a thin notifier test: rules are covered as pure functions, and
`game_notifier_test.dart` covers only what lives in the notifier — countdown, ticking, pause/resume,
stop on finish, error flash, size clamping, timer disposal. Persistence is covered through
`SessionCompleter`, not through `GameScreen`. The cost is that the wiring between layers is not
asserted (see Known gaps).

**Coverage report:** produced in CI for visibility as an `lcov.info` artifact, with no threshold
(`.github/workflows/ci.yml:57-65`).

**Known gaps** (tested neither directly nor through a caller):

- `GameScreen` → `SessionCompleter.complete` wiring and its `_finished` guard
  (`features/game/screens/game_screen.dart:72-76, 195`) — a silent no-op here is the bug class this
  change was written about.
- `GameNotifier.tapCell` Gorbov dispatch (`game_provider.dart:347-349`); Gorbov completion is not
  asserted to be false one tap early, so `&&` → `||` in `GameState.isCompleted`
  (`models/game_state.dart:82`) would pass.
- Beating an *existing* record (`records_provider.dart:52`); only first records and slower/equal
  times are tested.
- `rescheduleFromStorage` key reads and defaults (`notification_service.dart:89-110`).
- `ParentPinScreen` has no widget test: setup/confirm flow, wrong-PIN wiring, numpad disabled while
  locked (`parent_pin_screen.dart:55, 80-100, 132, 284, 296`); router PIN guard (`app/router.dart:37-41`).

## Context

Before this change the suite had 126 passing tests (after `test-suite-stabilization`) across
constants, models, pure functions, services and a few widgets. The easily testable was tested; the
hard parts were left.

Covered then: Gorbov grid generation and tap logic (pure functions), record key migration, model
serialisation, `LeaderboardEntry`, `DeviceIdService`, several screen smoke tests.

Not covered: the game loop for four modes (classic, reverse, letters, Gorbov) — tap validation for
classic/reverse/letters lived in private `GameNotifier` methods, and session and record persistence
lived in the `GameScreen` widget. Reminder scheduling decisions were mixed with platform calls.
Achievement conditions and the PIN lockout were not covered, and the lockout reset whenever the
screen was left.

Two confirmed bugs from the audit lived in these gaps: `ShareCard` looked up a record on a
string-keyed map with an int key and always got null, and the reverse/letters records were not
reloaded after restart, so every result counted as a record. Both survived because nothing asserted
the behaviour. (The parent session time limit, cited in the first draft, has since been removed from
the product.)

## Goals / Non-Goals

**Goals:**
- Cover the behaviours whose failure a user would actually notice.
- Make silent no-ops — the failure mode behind the confirmed bugs — detectable.
- Add coverage without reintroducing the suite pathologies just fixed.

**Non-Goals:**
- A coverage percentage target. It is satisfied fastest by testing trivial code.
- Testing generated localizations, Hive adapters or constant declarations.
- Golden or screenshot tests.
- Testing framework behaviour — that GoRouter routes or that Riverpod notifies.

## Decisions

**Prioritise by cost of silent failure, not by ease.** Game loop, reminders, achievements, PIN
lockout — each fails silently.

**Extract the rule, test it pure; keep the notifier test thin.** (Revised; see Outcome.) Rules move
into pure functions or small classes with injected dependencies; the notifier test covers only
timing and state transitions that exist nowhere else.

**Assert observable behaviour, never internal structure.** A test asserting a field is set would have
passed for both confirmed bugs. Boundary tests assert both sides of each threshold so that inverting a
condition fails a test.

**Fake time rather than wait on it.** `fakeAsync` where the code owns `Timer`s (`GameNotifier`);
an injected clock or `now` where the code only reads the time (`PinLockout`, `planReminder`).

**Test decision logic, not platform delivery.** Notification delivery, haptics and sound are not
exercised; tests disable sound/haptics via the user box and inject the reminder call.

**`share_card_test.dart` stays with its bug fix.** It was rewritten in `328de3d` to build the card
through the production `ShareCard.fromState` factory; it is listed here as context, not claimed by
this change.

## Risks / Trade-offs

- **Pure extraction leaves wiring untested** → Accepted for now; the gaps are listed in Outcome. A
  single `GameScreen` widget test that finishes a grid and checks the saved session would close the
  largest one.
- **Suite runtime** → Unit tests preferred over widget tests; 267 tests run in ~5 s against a 3-minute
  budget.
- **Order dependence** → Each new file uses its own temp Hive directory, clears boxes in `setUp` and
  builds a fresh `ProviderContainer` per test.
- **Achievement tests encode conditions** → Each test checks both sides of the boundary, so inverting
  a condition fails it.

## Migration Plan

Done: prerequisites landed; game loop, session completion, reminder plan, achievement rules and PIN
lockout covered in that order. Remaining: CI run on GitHub (External).

**Rollback:** tests are additive; the refactors are behaviour-preserving extractions.

## Open Questions (resolved)

- Does `GameNotifier` need refactoring to be testable? — Yes; the extractions are listed in Outcome.
- Should a coverage report be produced? — Yes, as a CI artifact without a threshold.
- Does `integration_test/screenshot_test.dart` still serve a purpose? — Out of scope here; not
  evaluated by this change.
