## Status (2026-10-25)

- **Outcome:** the suite is green and terminates — maintainer-reported local run: 267 tests in ~5 s. CI runs `flutter test --reporter expanded --timeout 60s --coverage` inside a 10-minute job on Flutter 3.47.6 (`.github/workflows/ci.yml:28`, `:47`, `:57`); runs on `main` are never cancelled (`ci.yml:18-22`).
- **The league deadlock is worked around, not root-caused.** The rename-dialog tests were split out of `test/features/league/league_screen_test.dart` into `test/features/league/league_edit_name_test.dart` (2 tests) and `test/features/league/league_edit_name_cancel_test.dart` (1 test). Removing `autofocus` did **not** fix it (`brainy-app/lib/features/league/screens/league_screen.dart:179-182`).
- **Guard:** no test file may hold more than two tests that open the rename dialog (see `design.md`).
- **New lesson:** Hive writes started inside a `testWidgets` fake-async zone never complete and block Hive's queue for later tests (see `design.md`, `brainy-app/test/home/home_screen_test.dart:36-37`, `:76-77`, `:86-87`).
- **Remaining:** External only — first green CI run on GitHub, and making the job a required check (`tasks.md` 5.1, 5.2).

The sections below are the original proposal, kept for history. Counts and timings in them describe the state before the fix.

## Why

`flutter test` was red and took 20 minutes. Two tests in `test/features/league/league_screen_test.dart` wedged the test isolate so hard that even `--timeout 45s` did not fire; the runner eventually died with `Bad state: Cannot close sink while adding stream` from `flutter_tools/src/test/flutter_platform.dart:766`. Every test in that file passed in isolation in under a second — the deadlock only appeared from the seventh consecutive test onward. Until this was fixed the CI gate introduced by `ci-quality-gate` could not pass.

## What Changes

- League screen tests stop using `pumpAndSettle` while the rename dialog is open and stop using unbounded `scrollUntilVisible`, both of which can spin until the per-test timeout.
- Every test that opens a dialog closes it before finishing, so no test hands an open route to the next one.
- The rename-dialog tests move into their own files (workaround, labelled as such in the file headers). The planned fix — removing `autofocus` — was tried and did not help; it stays removed as a UX choice only.
- The rename dialog's production defects found along the way are fixed: controller disposal, awaited Hive write, notifier read before the await, double-tap guard.
- `flutter test` completes green within the CI budget (60 s per test, 10 min per job).

## Capabilities

### New Capabilities
- `test-suite-health`: the properties the automated test suite must hold — terminating, order-independent, bounded, compiling, and diagnosable.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for test infrastructure. -->

## Impact

- `brainy-app/test/features/league/league_screen_test.dart` — non-dialog tests only (5).
- `brainy-app/test/features/league/league_edit_name_test.dart`, `league_edit_name_cancel_test.dart` — new; the rename-dialog tests with workaround headers.
- `brainy-app/lib/features/league/screens/league_screen.dart` — `_EditNameDialog`, no `autofocus`, awaited write, double-tap guard.
- `brainy-app/test/home/mode_toggle_test.dart` and `brainy-app/test/constants/app_constants_test.dart` — load failures fixed by `revenuecat-removal-cleanup`; confirmed green in the full run.
- `.github/workflows/ci.yml` — able to pass; not yet run on GitHub.
