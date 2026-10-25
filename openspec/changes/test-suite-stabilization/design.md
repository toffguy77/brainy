## Decision / Outcome (2026-10-25)

**Status: worked around, not root-caused.** The suite is green and terminates — maintainer-reported local run: 267 tests in ~5 s. CI runs it as `flutter test --reporter expanded --timeout 60s --coverage` in a job with `timeout-minutes: 10` on Flutter 3.47.6 (`.github/workflows/ci.yml:28`, `:47`, `:57`); runs on `main` are never cancelled (`ci.yml:18-22`). CI has not yet run on GitHub.

- **Workaround:** the three rename-dialog tests live in `brainy-app/test/features/league/league_edit_name_test.dart` (2) and `league_edit_name_cancel_test.dart` (1), each with a header saying so (`league_edit_name_test.dart:14-32`, `league_edit_name_cancel_test.dart:14-19`). `league_screen_test.dart` keeps the five non-dialog tests.
- **Autofocus was not the fix.** Removing it changed nothing; it stays removed as a UX choice only (`brainy-app/lib/features/league/screens/league_screen.dart:179-182`).
- **Dialog hardening (commit 1e1e279):** `_EditNameDialog._save` ignores a second tap while saving (`league_screen.dart:146-147`) and reads the `playerNameProvider` notifier before awaiting the Hive write (`:152`, `:157`).
- **Guard (standing rule):** no test file may contain more than two tests that open the rename dialog. Until the cause is known, a new dialog test goes into a new file, not into one of the existing two. Treat any test file that opens a dialog in three or more tests the same way.
- **Lesson — Hive inside fake async:** in `testWidgets`, a Hive write started inside the fake-async zone never completes, and because Hive serialises box operations it blocks every later operation on that box — including the next test's `setUp` `clear()` and a `Hive.close()` in `tearDownAll`. Rules: seed Hive in `setUp` (outside the zone); run UI-triggered writes you need to finish inside `tester.runAsync`; do not `Hive.close()` in `tearDownAll` in such files. Reference implementation: `brainy-app/test/home/home_screen_test.dart:36-37`, `:76-77`, `:86-87`, `:124`, `:163`.
- **Unverified hypothesis for the root cause** (not tested, recorded so the next investigation starts here): the lesson above fits the original symptoms better than the "three-dialog threshold". In the pre-split file at `681dd86`, the sixth test (`edit name dialog saves custom name to Hive`, tapping Save at line 203) started a `box.put` from the fake-async zone; the seventh test was the first to deadlock, and its `setUp` awaits `box.clear()` (line 40) on the same box. Today the save test is the **last** test in `league_edit_name_test.dart` (`:119-130`), so nothing waits on its write. To test: put the save tap inside `tester.runAsync` and merge the files back.

Counts and timings below ("126 tests", "8.7 seconds", "three minutes") are **historical** — they describe the state at the time of the investigation, not the current suite.

## Context

`test/features/league/league_screen_test.dart` has eight tests. Six pass in well under a second. From the seventh, the test isolate deadlocks: `--timeout 45s` does not fire, and after several minutes `flutter_tools` dies with `Bad state: Cannot close sink while adding stream` at `flutter_platform.dart:766`. In a default run each wedged test burns the 10-minute per-test timeout, which is why `flutter test` takes 20 minutes.

The tests arrived with `681dd86` ("allow player to edit display name in league screen"). They reached `main` red because no CI job ran them.

Investigation established:

- Every test passes in isolation (`--plain-name`), including both that fail in the full run.
- Running only the three rename-dialog tests together reproduces the deadlock.
- The failure is not in a test body — a test-level timeout would fire. The runner's own channel breaks, which points at the binding or the platform-channel layer.
- The dialog's `TextField` sets `autofocus: true`, opening a platform text-input connection. The first dialog test never closed its dialog, handing the next test an open route and a live input connection.

Four fixes were applied during investigation. Three are genuine defects, fixed and kept; none removed the deadlock:

- The dialog's `TextEditingController` was never disposed. Moving it into a `StatefulWidget` (`_EditNameDialog`) that disposes it correctly is a real leak fix. Disposing via `showDialog(...).whenComplete` was tried first and is wrong — it throws "A TextEditingController was used after being disposed", because the field still rebuilds while the route animates out.
- `box.put(customPlayerNameKey, newName)` was fired without `await`, racing the next read.
- The tests used unbounded `scrollUntilVisible` and `pumpAndSettle` around a blinking cursor.

## Goals / Non-Goals

**Goals:**
- `flutter test` terminates, green, fast enough to gate a deploy.
- The league tests behave identically alone and together.
- The suite stops hiding failures behind load errors and log spam.

**Non-Goals:**
- Broadening test coverage. That is `test-coverage-expansion`.
- Fixing the `flutter_tools` shutdown error upstream. It is a symptom; the goal is to stop triggering it.
- Fixing the two load failures directly — they are caused by removed RevenueCat constants and are resolved by `revenuecat-removal-cleanup`. This change only verifies they stay green in a full run.

## Decisions

**Treat `autofocus: true` as the prime suspect and test removing it first.** It is the one element unique to the deadlocking tests, it is the only thing opening a platform text-input connection, and it is cheap to test. Its UX value is modest — the rename dialog is a two-field interaction where the user has already tapped deliberately, so tapping the field is no hardship. If removing it clears the deadlock, that is the fix.

**If `autofocus` is not the cause, split the dialog tests into their own file.** This is a workaround, not a fix, and must be labelled as one in a comment: it isolates the leak into a fresh isolate rather than stopping the leak. Acceptable as a fallback because a green, terminating suite gating every deploy is worth more than an elegant single file.

*Alternative considered:* delete the two failing tests. Rejected — they cover the feature that `681dd86` shipped, and deleting tests to get green is the failure mode this whole audit exists to correct.

**Keep the three production fixes regardless of which path resolves the deadlock.** The controller leak, the unawaited Hive write, and the missing dialog cleanup are defects on their own terms. They stay whether or not they were the trigger.

**Bounded pumps over `pumpAndSettle` near animated widgets, as a standing rule.** `pumpAndSettle` pumps until no frame is scheduled. A blinking cursor and a `CircularProgressIndicator` schedule frames forever, so the call can only end at the timeout. Two `pump` calls — one to process the tap, one to advance past the route transition — are deterministic and fast.

**Assert the suite's wall-clock budget.** Speed is the property that makes the CI gate usable; without a stated budget it degrades silently. Three minutes was generous for the then-current 126 tests (historical). Superseded: the enforced budget is now the CI one — 60 s per test, 10 minutes per job.

## Risks / Trade-offs

- **Removing `autofocus` does not fix it either** → Fall back to the file split, and record in this document what was ruled out so the next person does not repeat the investigation.
- **The file split hides a leak that resurfaces elsewhere** → Mitigated by the order-independence requirement, which is written against the whole suite, not just this file.
- **Bounded pumps are flakier than `pumpAndSettle` if a transition is slower than the pumped duration** → 300ms exceeds the Material dialog transition; if a slower animation is introduced the test fails loudly rather than hanging, which is the correct failure mode.
- **The three-minute budget becomes a nuisance as coverage grows** → It is a ceiling on the suite, not a per-test limit; revisit it in `test-coverage-expansion` if genuinely exceeded.

## Migration Plan

1. Land `revenuecat-removal-cleanup` so the two load failures are gone and the full-run signal is clean.
2. Remove `autofocus: true`; run the full file; run the full suite.
3. If green, done. If not, split the dialog tests into a separate file with an explanatory comment and re-run.
4. Time a clean run and record it against the three-minute budget.
5. Enable the `flutter` job in `ci-quality-gate` as a required check.

**Rollback:** all edits are ordinary reverts. The suite's current state is already red, so no intermediate state is worse than the starting point.

## Outcome

*(Historical, at the time of the split.)* Resolved by the file split. `flutter test` then reported **126 passed in 8.7 seconds**, against a starting point of 4 failures and a 20-minute run.

`autofocus` was **not** the cause — removing it changed nothing. Neither did releasing focus immediately after `enterText` while the field was still mounted.

The decisive observation came late: the first six tests always passed, including two that open the dialog. Two dialog-opening tests coexist; a third deadlocks. That is a threshold, not a property of any individual test, which is why every per-test fix failed.

Ruled out, each verified by a full run:

- disposing the `TextEditingController` via a `StatefulWidget` — a real leak, fixed and kept
- awaiting the Hive write — a real race, fixed and kept
- bounded pumps instead of `pumpAndSettle` and `scrollUntilVisible` — kept
- closing the dialog in the test that left it open — kept
- removing `autofocus: true`
- unfocusing immediately after `enterText`

The three dialog tests now live in `league_edit_name_test.dart` (two) and `league_edit_name_cancel_test.dart` (one), each carrying a header stating this is a workaround and recording what was ruled out.

## Open Questions

- What is the actual cause of the three-dialog threshold? Unresolved; see the Hive/fake-async hypothesis at the top of this document. The workaround holds, but the underlying leak is still there and could resurface in another file that opens three dialogs.
- Does the same leak affect `integration_test/screenshot_test.dart`, which drives the same screens? Not observed, but it has never run in CI.
- Should `flutter test --reporter failures-only` be the CI default to keep logs readable, at the cost of losing progress output on a hang?
