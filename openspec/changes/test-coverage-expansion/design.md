## Context

The suite has 118 passing tests across constants, models, pure functions, services and a few widgets. Its shape reveals its history: the easily testable was tested, and the hard parts were left.

What is covered: Gorbov grid generation and tap logic (pure functions), record key migration, model serialisation, `LeaderboardEntry`, `DeviceIdService`, several screen smoke tests.

What is not: `GameNotifier` — the timer, tap validation, penalty application, completion detection, coin and XP award, session and record persistence, for two modes. `NotificationService.reschedule()` — three branches, custom-time handling, two text pools, three call sites. `AchievementsProvider` — ten unlock conditions evaluated after every session. `ParentPinScreen` — PIN set and verify, three-attempt limit, 30-second lockout.

The Gorbov helpers are the telling case. They were deliberately extracted as pure functions "for testability" and tested — but the notifier that calls them was not. The intent was right and stopped at the boundary of what is awkward to test.

Two confirmed bugs from the audit lived in these gaps. `ShareCard` looked up `records[5]` on a string-keyed map and always got null. The parent session limit was stored, read into state, and never consulted by the game. Neither is subtle; both survived because nothing asserted the behaviour.

## Goals / Non-Goals

**Goals:**
- Cover the behaviours whose failure a user would actually notice.
- Make silent no-ops — the failure mode that produced both confirmed bugs — detectable.
- Add coverage without reintroducing the suite pathologies just fixed.

**Non-Goals:**
- A coverage percentage target. It would be satisfied fastest by testing the trivial code that is already implicitly correct, which is how the current shape arose.
- Testing generated localizations, Hive adapters or constant declarations. `app_constants_test.dart` already tests some constants; that is enough.
- Golden or screenshot tests. High maintenance, and the existing integration test covers visual output for store screenshots.
- Testing framework behaviour — that GoRouter routes or that Riverpod notifies.

## Decisions

**Prioritise by cost of silent failure, not by ease.** The four targets are ranked by what breaks if they are wrong: the game loop is the product; notifications drive retention and their logic is branchy and invisible when wrong; achievements are the reward system; the PIN lockout is a security-adjacent control. Each fails silently, which is precisely the class of bug the audit found twice.

**Test the notifier, not just the pure functions.** The pure Gorbov functions are already covered and were never the risk. The risk is in the notifier that wires them to state and persistence — where `ShareCard`-style mistakes live.

**Assert observable behaviour, never internal structure.** Written into the spec with a scenario requiring that deliberately breaking a behaviour fails its test. A test asserting a field is set would have passed for both confirmed bugs; a test asserting the share card shows a record, or that the game ends at the limit, would not.

**Fake time rather than wait on it.** The game timer, the notification schedule and the PIN lockout are all time-dependent. Real waits make a suite slow and flaky — and `test-suite-stabilization` exists because of a suite that hung. Inject a clock or use `fakeAsync`.

**Sequence after stabilization and after the free-release change.** Adding tests to a suite that deadlocks makes the deadlock harder to isolate. Writing tests against premium-gated paths about to be deleted wastes the work.

**Do not fold `share_card_test.dart` into this change.** It belongs with the bug fix that motivates it, where it can be verified to fail before the fix and pass after — which is stronger evidence than a test written afterwards.

## Risks / Trade-offs

- **`GameNotifier` may be hard to test as written** → Likely, and informative: if it cannot be tested without a widget tree, that is a design signal. Refactor for testability only as far as needed; do not restructure the game loop under cover of a test change.
- **Suite runtime grows past its budget** → Prefer unit tests over widget tests where the logic allows; measure after each addition rather than at the end.
- **Notification tests depend on `timezone` and platform channels** → Test the decision logic — which branch, what time, which pool — rather than the platform delivery.
- **New tests reintroduce order dependence** → The spec requires each new test to pass alone and in the full suite, the exact check that exposed the league deadlock.
- **Achievement tests encode conditions rather than verify them** → Derive each test from the condition in code, then confirm it fails when that condition is inverted.

## Migration Plan

1. Land `test-suite-stabilization` and `remove-monetization-go-free`.
2. `GameNotifier` first — highest value, and likely to surface testability problems worth knowing about early.
3. `NotificationService.reschedule()` — most branches per line of code.
4. `AchievementsProvider` — one test per condition.
5. `ParentPinScreen` — including lockout expiry with faked time.
6. After each, run the full suite and check the wall-clock budget.

**Rollback:** tests are additive; removing them restores the prior state without affecting the app.

## Open Questions

- Does `GameNotifier` need refactoring to be testable, and if so, how much is justified within this change?
- Should a coverage report be produced for visibility, without becoming a threshold?
- Does `integration_test/screenshot_test.dart` still serve a purpose after `remove-monetization-go-free` deletes screens it captures?
