## 1. Prerequisites

- [x] 1.1 Confirm `test-suite-stabilization` has landed and the suite is green and terminating
- [x] 1.2 Confirm `remove-monetization-go-free` has landed so no test targets deleted code
- [x] 1.3 Record the baseline suite runtime to measure growth against

## 2. Cover the game loop

- [ ] 2.1 Decide how to control time in `GameNotifier` tests (injected clock or `fakeAsync`)
- [x] 2.2 Test that a correct tap marks the cell found and advances the expected number
- [x] 2.3 Test that an incorrect tap increments mistakes and applies the time penalty
- [x] 2.4 Test classic-mode completion at the final number
- [x] 2.5 Test Gorbov-mode alternation and that completion requires both sequences exhausted
- [ ] 2.6 Test that a completed session is persisted with grid size, duration, mistakes, mode and coins
- [ ] 2.7 Test that a personal record is written under the correct `{mode}_{size}` key when beaten
- [ ] 2.8 Test that a slower session does not overwrite an existing record
- [ ] 2.9 Note any refactoring required for testability, and keep it minimal

## 3. Cover notification rescheduling

- [ ] 3.1 Test that disabled notifications cancel and schedule nothing
- [ ] 3.2 Test that having played today cancels and schedules nothing
- [ ] 3.3 Test that not having played schedules a notification
- [ ] 3.4 Test that a custom reminder time is honoured over the default
- [ ] 3.5 Test that the streak-warning pool is chosen above the streak threshold
- [x] 3.6 Test that variant selection is deterministic for a given day
- [x] 3.7 Keep the tests on decision logic, not platform delivery

## 4. Cover achievements

- [x] 4.1 Enumerate the shipped `AchievementId` values as the authority
- [ ] 4.2 Test that each condition unlocks its achievement — NOT done: `achievements_test.dart` covers catalogue integrity (ids, keys, assets), not the unlock conditions. `checkAchievements` takes a `WidgetRef`, so testing conditions needs either a widget harness or a refactor to take a plain `Ref`
- [ ] 4.3 Test that an already-unlocked achievement is not awarded twice
- [ ] 4.4 Confirm each test fails when its condition is inverted

## 5. Cover PIN protection

- [x] 5.1 Test that a first four-digit entry sets the PIN and grants access
- [x] 5.2 Test that the correct PIN verifies
- [x] 5.3 Test that an incorrect PIN is refused and counted
- [ ] 5.4 Test that reaching the attempt limit triggers the lockout
- [ ] 5.5 Test that the lockout expires after its duration, using faked time

## 6. Keep the suite healthy

- [x] 6.1 Run each new test alone and in the full suite; confirm identical results
- [x] 6.2 Confirm no new test uses an unbounded wait
- [x] 6.3 Confirm the full suite stays within its wall-clock budget
- [ ] 6.4 Confirm the CI gate still passes within its ten-minute limit
- [ ] 6.5 Decide whether to produce a coverage report for visibility, without setting a threshold
