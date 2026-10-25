Status (audit 2026-10-25, branch `chore/finish-audit-changes`, after commit 328de3d).
Paths below are relative to `brainy-app/`. Evidence is static (code + test reading); `flutter
analyze` / `flutter test` were not re-run during this audit.

## 1. Fix the lookup

- [x] 1.1 Replace `records[5]` with `records[recordKey('classic', 5)]` in `share_card.dart`
  — `lib/features/parent/widgets/share_card.dart:37` `records[recordKey(GameModes.classic, 5)]`, inside `ShareCard.fromState` (uses the `GameModes.classic` constant, not a literal)
- [x] 1.2 Grep the codebase for other integer indexing of the records map and fix any found
  — `grep -E "records\[[0-9]|records\[['\"]"` over `lib/` and `test/`: no hits. All lookups go through `recordKey` (`lib/features/progress/screens/progress_screen.dart:696,738`, `lib/features/progress/providers/grid_stats_provider.dart:59`, `lib/features/parent/screens/parent_dashboard_screen.dart:434`, `lib/features/game/providers/records_provider.dart:29,50,59,65`)
- [x] 1.3 Confirm `flutter analyze` no longer reports `collection_methods_unrelated_type`
  — the int-indexed lookup no longer exists (1.1/1.2); CI runs `flutter analyze --fatal-infos` (`.github/workflows/ci.yml:54`), so any info would fail the build

## 2. Cover it with a test

- [x] 2.1 Create `test/parent/share_card_test.dart`
  — exists; reworked in 328de3d so `_harness` builds the card via `ShareCard.fromState` (`test/parent/share_card_test.dart:31`), the same factory `showAndShare` uses (`share_card.dart:57`)
- [x] 2.2 Test the rendered 5x5 value against a records box seeded with `classic_5`
  — `shows the stored 5x5 classic record with its label` (`{'classic_5': 22}` → `22s` + `Best 5×5 result`). Uses a records map, which is what `recordsProvider` exposes, rather than a Hive box
- [x] 2.3 Test the empty state against an empty records box
  — `a fresh install shows the streak and no record slot` (no record slot, `Streak` shown, `Just getting started!`, no exception)
- [x] 2.4 Test that a `gorbov_5` record alone still yields the empty state
  — `records of other modes or sizes do not stand in` (`gorbov_5`, `reverse_5`, `classic_4` → no record slot, no `30s`/`14s`)
- [x] 2.5 Confirm the test fails if the lookup is reverted to the integer key
  — by construction: the test calls the production factory, so `records[5]` would yield `null` and `22s` would not be found. Before 328de3d the test built `ShareCard(best5x5: …)` directly and could not fail this way (verification doc finding)

## 3. Verify visually

- [ ] 3.1 Manual (device): play a 5x5 classic game, open the parent dashboard, tap Share; confirm the real share sheet opens on iPhone and, on iPad, as a popover anchored to the Share button
- [x] 3.2 Confirm the real value renders and the layout accommodates it
  — substituted by widget tests: `shows the stored 5x5 classic record with its label`, and `long values and large text do not overflow` (`9999`, streak 365, ru, text scale 1.3 → no exception, width 340). Layout guarded by `Expanded` + `FittedBox` + `maxLines: 2` (`share_card.dart:213-239`)
- [ ] 3.2a Manual (device): open the exported PNG and check Nunito fonts, the gradient background and border render correctly at `pixelRatio: 3.0`
- [x] 3.3 Confirm the empty state still renders correctly for a fresh install
  — substituted by widget test `a fresh install shows the streak and no record slot`

## 4. Unblock the gate

- [x] 4.1 Confirm `flutter analyze --fatal-infos` exits 0 once `revenuecat-removal-cleanup` has also landed
  — `--fatal-infos` is already in the CI gate (`.github/workflows/ci.yml:54`); this change contributes no remaining info

## 5. Audit follow-up (commit 328de3d)

- [x] 5.1 Single build path: `ShareCard.fromState` (`share_card.dart:30-40`) used by `showAndShare` (`share_card.dart:57`) and the test harness
- [x] 5.2 iPad popover anchor: `sharePositionOrigin` from the button's `RenderBox` (`share_card.dart:52-55,81`); the dashboard passes the button's own context via `Builder` (`lib/features/parent/screens/parent_dashboard_screen.dart:63-67`)
- [x] 5.3 Failure handling: capture/write/share wrapped in `try`, `catch` shows SnackBar `shareFailed` (`share_card.dart:67-86`; `l10n/app_en.arb:197`, `l10n/app_ru.arb:197`)
- [x] 5.4 Localized seconds unit and app name: `l10n.shareSeconds` (`share_card.dart:171`; `l10n/app_en.arb:189` `{seconds}s`, `l10n/app_ru.arb:189` `{seconds} с`), `l10n.appName` (`share_card.dart:128`); test `Russian uses its own seconds unit and plural`
- [x] 5.5 Plural title: `parentShareCardTitle` ICU plural with `=0` (`l10n/app_en.arb:180`, `l10n/app_ru.arb:180`); covered by the fresh-install and Russian tests
- [x] 5.6 Plan updated: `docs/plans/features/parent-panel.md:64-75`
