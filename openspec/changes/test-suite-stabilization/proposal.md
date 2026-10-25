## Why

`flutter test` is red and takes 20 minutes. Two tests in `test/features/league/league_screen_test.dart` wedge the test isolate so hard that even `--timeout 45s` does not fire; the runner eventually dies with `Bad state: Cannot close sink while adding stream` from `flutter_tools/src/test/flutter_platform.dart:766`. Every test in that file passes in isolation in under a second — the deadlock only appears from the seventh consecutive test onward. Until this is fixed the CI gate introduced by `ci-quality-gate` cannot pass, so it blocks the one control that would stop this class of defect from recurring.

## What Changes

- The autofocused `TextField` in the league rename dialog stops leaking a platform text-input connection between tests, removing the deadlock.
- League screen tests stop using `pumpAndSettle` while a blinking cursor is on screen and stop using unbounded `scrollUntilVisible`, both of which spin until the 10-minute per-test timeout.
- Every test that opens a dialog closes it before finishing, so no test hands an open route to the next one.
- `flutter test` completes green, and fast enough to sit in front of a deploy.

## Capabilities

### New Capabilities
- `test-suite-health`: the properties the automated test suite must hold — terminating, order-independent, and honest about failure.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for test infrastructure. -->

## Impact

- `brainy-app/test/features/league/league_screen_test.dart` — dialog helpers, bounded pumps, dialog cleanup.
- `brainy-app/lib/features/league/screens/league_screen.dart` — the rename dialog, if removing `autofocus` proves to be the fix.
- `brainy-app/test/home/mode_toggle_test.dart` and `brainy-app/test/constants/app_constants_test.dart` — both failed to load in the full run; the load failures are fixed by `revenuecat-removal-cleanup`, and this change confirms they stay green in a full run.
- `.github/workflows/ci.yml` — becomes able to pass.
