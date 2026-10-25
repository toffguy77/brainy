## Why

The test suite covers the easy things and skips the load-bearing ones. 118 tests pass, but the areas with the most logic and the highest cost of failure have none.

`GameNotifier` — the core game loop, driving the timer, tap validation, mistake penalties, completion detection and session creation for both modes — has no tests. Only the pure Gorbov helpers (`generateGorbovGrid`, `processGorbovTap`) are covered, and they were extracted specifically to be testable, which shows the intent existed and stopped short.

`NotificationService.reschedule()` has three branches (disabled, already played today, schedule) plus custom-time handling and two text pools, and is called from three places. No tests.

`AchievementsProvider` evaluates ten unlock conditions after every session. No tests.

`ParentPinScreen` implements PIN setting, verification, a three-attempt limit and a 30-second lockout — a security-adjacent control protecting the parent area. No tests.

Two of the audit's confirmed bugs sat in exactly these gaps: the `ShareCard` record lookup never worked, and the parent session time limit was never wired up. Both would have been caught by a single test asserting observable behaviour.

## What Changes

- `GameNotifier` gains coverage for both modes: correct and incorrect taps, mistake penalties, completion, session and record writing.
- `NotificationService.reschedule()` gains coverage for all three branches and custom-time handling.
- `AchievementsProvider` gains coverage for each unlock condition and for not re-awarding.
- `ParentPinScreen` gains coverage for set, verify, wrong PIN, attempt limit and lockout expiry.
- New tests follow the properties established by `test-suite-stabilization`: order-independent, bounded waits, no hangs.
- The suite stays within its wall-clock budget.

## Capabilities

### New Capabilities
- `behavioural-test-coverage`: which behaviours must be covered by automated tests, and to what standard.

### Modified Capabilities
<!-- None: `test-suite-health` in `test-suite-stabilization` covers suite mechanics; this covers what is tested. -->

## Impact

- `test/game/game_provider_test.dart` — new.
- `test/services/notification_service_test.dart` — new.
- `test/progress/achievements_provider_test.dart` — new.
- `test/parent/parent_pin_screen_test.dart` — new.
- `test/parent/share_card_test.dart` — created by `share-card-record-key-fix`.
- Suite runtime grows; must stay within the budget set by `test-suite-stabilization`.

Sequencing: after `test-suite-stabilization` (so new tests are added to a green, terminating suite) and after `remove-monetization-go-free` (so no test is written against code about to be deleted).
