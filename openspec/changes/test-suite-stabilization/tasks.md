## 1. Clear the load failures first

- [ ] 1.1 Land `revenuecat-removal-cleanup` so `app_constants_test.dart` and `mode_toggle_test.dart` compile
- [x] 1.2 Run the full suite and confirm no file fails at the `loading <path>` stage

## 2. Keep the production fixes found during investigation

- [x] 2.1 Move the rename dialog into `_EditNameDialog` (StatefulWidget) so it owns and disposes its `TextEditingController`
- [x] 2.2 `await` the Hive write in the dialog's save handler and capture `Navigator` before the await
- [x] 2.3 Replace unbounded `scrollUntilVisible` with `ensureVisible` in the league tests
- [x] 2.4 Replace `pumpAndSettle` around the open dialog with bounded `pump` calls
- [x] 2.5 Close the dialog in the test that previously left it open

## 3. Resolve the deadlock

- [x] 3.1 Remove `autofocus: true` from the rename dialog's `TextField`
- [x] 3.2 Run `flutter test test/features/league/league_screen_test.dart` and record whether the deadlock clears
- [x] 3.3 If it clears, run the full suite to confirm; if not, proceed to 3.4
- [x] 3.4 Fallback: move the three rename-dialog tests into their own file with a comment stating this is a workaround for an inter-test leak, not a fix
- [x] 3.5 Record in `design.md` what was ruled out, so the investigation is not repeated

## 4. Prove the properties hold

- [x] 4.1 Run each league test alone with `--plain-name` and confirm results match the full-file run
- [x] 4.2 Confirm no `TimeoutException` anywhere in the suite output
- [x] 4.3 Confirm no `Bad state: Cannot close sink while adding stream` in the output
- [x] 4.4 Time a clean `flutter test` run and confirm it is under three minutes
- [x] 4.5 Confirm the output is free of thousands of repeated progress lines

## 5. Gate on it

- [ ] 5.1 Confirm the `flutter` job in `.github/workflows/ci.yml` passes against the fixed suite
- [ ] 5.2 Make that job a required status check on `main`
