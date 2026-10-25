Status legend: `[x]` done (evidence cited), `[~]` dropped / not applicable (reason given), `[ ]` open — External work only.
Paths below are relative to `brainy-app/` unless they start with `.github/` or `openspec/`.

## 1. Clear the load failures first

- [x] 1.1 Land `revenuecat-removal-cleanup` so `app_constants_test.dart` and `mode_toggle_test.dart` compile — the part this change depends on is done: `openspec/changes/revenuecat-removal-cleanup/tasks.md:15` (RevenueCat group removed from `test/constants/app_constants_test.dart`); neither test file references `revenueCat*` / `isPremium` any more (grep of both files is empty). That change's own remaining tasks (fastlane, secret, analyzer) are tracked there, not here.
- [x] 1.2 Run the full suite and confirm no file fails at the `loading <path>` stage — maintainer-reported full local run: 267 tests passed in ~5 s, no load failures.

## 2. Keep the production fixes found during investigation

- [x] 2.1 Move the rename dialog into `_EditNameDialog` (StatefulWidget) so it owns and disposes its `TextEditingController` — `lib/features/league/screens/league_screen.dart:109`, `:117-141` (`dispose()` at `:139-141`).
- [x] 2.2 `await` the Hive write in the dialog's save handler and capture `Navigator` before the await — `league_screen.dart:149` (navigator captured), `:157` (`await box.put`), `:160` (`if (mounted) navigator.pop()`). Commit 1e1e279 additionally reads the notifier before the await (`:152`) and guards double taps with `_saving` (`:129`, `:146-147`).
- [x] 2.3 Replace unbounded `scrollUntilVisible` with `ensureVisible` in the league tests — `test/features/league/league_edit_name_test.dart:71`, `test/features/league/league_edit_name_cancel_test.dart:70`; no `scrollUntilVisible` call remains under `test/` (only a comment at `league_edit_name_test.dart:25`).
- [x] 2.4 Replace `pumpAndSettle` around the open dialog with bounded `pump` calls — `league_edit_name_test.dart:68-76`, `:87-90`; `league_edit_name_cancel_test.dart:71-83`. Remaining `pumpAndSettle` calls run only before the dialog opens (`league_edit_name_test.dart:108`, `:121`; `league_edit_name_cancel_test.dart:66`).
- [x] 2.5 Close the dialog in the test that previously left it open — `league_edit_name_test.dart:115-116` (taps Cancel and pumps the dismissal).

## 3. Resolve the deadlock

- [x] 3.1 Remove `autofocus: true` from the rename dialog's `TextField` — `league_screen.dart:177-182` has no `autofocus`; the comment there records it is kept off as a UX choice only.
- [x] 3.2 Run the league tests after removing `autofocus` and record whether the deadlock clears — recorded: it did **not** clear (`design.md` Outcome; `league_edit_name_test.dart:23-28`; `league_screen.dart:179-182`).
- [x] 3.3 Because removing `autofocus` did not clear the deadlock, proceed to 3.4 (the full-suite confirmation is done under 4.x after the split).
- [x] 3.4 Fallback: move the three rename-dialog tests into their own files with a comment stating this is a workaround for an inter-test leak, not a fix — `test/features/league/league_edit_name_test.dart` (2 tests, header `:14-32`) and `test/features/league/league_edit_name_cancel_test.dart` (1 test, header `:14-19`). `test/features/league/league_screen_test.dart` keeps the 5 non-dialog tests.
- [x] 3.5 Record in `design.md` what was ruled out, so the investigation is not repeated — `design.md` "Outcome" and "Ruled out"; also duplicated in `league_edit_name_test.dart:23-28`.

## 4. Prove the properties hold

- [x] 4.1 Run each league test alone with `--plain-name` and confirm results match the full-file run — done during the investigation (recorded in `design.md` Outcome); not re-run for this update.
- [x] 4.2 Confirm no `TimeoutException` anywhere in the suite output — maintainer-reported green run (267 passed, ~5 s); CI enforces it with `--timeout 60s` (`.github/workflows/ci.yml:57`).
- [x] 4.3 Confirm no `Bad state: Cannot close sink while adding stream` in the output — same maintainer-reported run; a recurrence would surface in CI as a failed or timed-out job (`ci.yml:28`).
- [x] 4.4 Time a clean `flutter test` run and confirm it fits the budget — ~5 s locally vs. the CI budget of `timeout-minutes: 10` for the whole job (`ci.yml:28`) and 60 s per test (`ci.yml:57`). The earlier three-minute target is superseded by these enforced limits.
- [x] 4.5 Confirm the output is free of thousands of repeated progress lines — the source of the spam (`scrollUntilVisible`) is gone (see 2.3); CI uses `--reporter expanded` (`ci.yml:57`).

## 5. Gate on it

- [ ] 5.1 External: confirm the `flutter` job in `.github/workflows/ci.yml` passes on GitHub against the fixed suite — the workflow has not run on GitHub yet.
- [ ] 5.2 External: make that job a required status check on `main` (branch protection; also tracked as `openspec/changes/ci-quality-gate/tasks.md:19`).
