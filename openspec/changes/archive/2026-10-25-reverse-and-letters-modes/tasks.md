Status as of 2026-10-25 (branch `chore/finish-audit-changes`, commits f0e1ec8..1e1e279). Paths are relative to `brainy-app/` unless noted. Only device play is still open.

## 1. Make the game loop safe to refactor

- [x] 1.1 Confirm `remove-monetization-go-free` has landed so no gating threads through the new modes. Done in f0e1ec8 and faf276b. `gridSizesForMode` (`lib/constants/app_constants.dart:197`) has no gating.
- [x] 1.2 Add `GameNotifier` tests covering classic and Gorbov before touching shared code. See `test/game/game_notifier_test.dart` (countdown, pause/resume, finish stops the clock, wrong-tap flash, route clamp, dispose cancels timers), `test/game/gorbov_tap_logic_test.dart` and `test/game/game_loop_test.dart`.
- [~] 1.3 Record the baseline: analyze clean, suite green. Superseded by 8.1 and 8.2. The pre-refactor baseline was not recorded separately, and the final state is what matters.

## 2. Generalise the grid model

- [x] 2.1 Change `GridCell` to carry a display string plus an ordinal position in the target sequence. `GridCell.number` is the ordinal, `label` is optional and `display => label ?? '$number'` (`lib/models/game_state.dart:4-30`).
- [x] 2.2 Update classic generation and validation to the ordinal model. `generateClassicGrid` (`game_provider.dart:15`) and `processOrdinalTap` (`game_provider.dart:153`).
- [x] 2.3 Keep Gorbov on its own two-sequence logic. `processGorbovTap` (`game_provider.dart:176`) is dispatched at `game_provider.dart:347`.
- [x] 2.4 Update `schulte_grid.dart` to render the display string rather than a number. `widget.cell?.display` (`lib/features/game/widgets/schulte_grid.dart:138`).
- [x] 2.5 Confirm classic and Gorbov tests stay green. See `test/game/ordinal_tap_test.dart` (classic group), `gorbov_tap_logic_test.dart` and `gorbov_grid_generation_test.dart`.

## 3. Reverse mode

- [x] 3.1 Add `generateReverseGrid` as a pure function. `game_provider.dart:37`: ordinal *i* shows `N²−i+1`.
- [~] 3.2 Add `processReverseTap` as a pure function. Not needed by design: reverse stores the ordinal in `number` and only the label is reversed, so the shared `processOrdinalTap` (`game_provider.dart:153`) validates it. A separate function would duplicate it.
- [x] 3.3 Test: first expected tap is N². See `reverse_and_letters_test.dart` "taps run from N² down to 1" and `ordinal_tap_test.dart` "expectedLabel … reverse starts at N² and ends at 1" (`'16'` on 4×4).
- [x] 3.4 Test: a correct tap advances downward. See `ordinal_tap_test.dart` "processOrdinalTap — reverse / a correct tap marks the cell found and advances".
- [x] 3.5 Test: an incorrect tap penalises and does not advance. See `ordinal_tap_test.dart` "processOrdinalTap — reverse / a wrong tap penalises and does not advance".
- [x] 3.6 Test: completion at 1. See `ordinal_tap_test.dart` "processOrdinalTap — reverse / the last ordinal finishes the game" and "reverse starts at N² and ends at 1".
- [x] 3.7 Reuse classic target times and star thresholds. `starThresholdsFor` falls through to `starThresholds` for reverse (`app_constants.dart:42`). `adaptiveTargetSeconds` uses the base target (`app_constants.dart:87`).

## 4. Letters mode

- [x] 4.1 Add Russian and Latin alphabets to `AppConstants`, excluding «Ё» and «Й». `alphabetRu` has 31 letters and `alphabetEn` has 26 (`app_constants.dart:173-181`). Test: "ambiguous Russian letters are excluded".
- [x] 4.2 Add `generateLettersGrid` as a pure function using a contiguous alphabet prefix. `game_provider.dart:62`. It throws `ArgumentError` beyond the alphabet length.
- [~] 4.3 Add `processLettersTap` as a pure function. Not needed by design: the letter ordinal is its alphabet position, so `processOrdinalTap` covers letters (see 3.2).
- [x] 4.4 Bound available sizes to 3, 4 and 5 using the shortest supported alphabet. `lettersGridSizes = [3, 4, 5]` (`app_constants.dart:166`). Tests: "only 3, 4 and 5 are offered" and "both alphabets are long enough for the largest offered grid".
- [x] 4.5 Test: first expected tap is the first letter. See `ordinal_tap_test.dart` "letters shows a letter, not a digit" (`'A'` then `'B'`) and `reverse_and_letters_test.dart` "a 3x3 Russian grid starts the alphabet at А".
- [x] 4.6 Test: every letter on the grid is distinct. See "every letter on the grid is distinct".
- [x] 4.7 Test: a 3×3 English grid contains exactly A–I. See "a 3x3 English grid contains exactly A through I".
- [x] 4.8 Test: positions are randomised while the letter set is fixed. See the test of the same name.
- [x] 4.9 Test: an incorrect tap penalises and does not advance. See `ordinal_tap_test.dart` "processOrdinalTap — letters / a wrong tap penalises and does not advance".
- [x] 4.10 Test: completion at the N²-th letter. See `ordinal_tap_test.dart` "processOrdinalTap — letters / the last ordinal finishes the game".
- [x] 4.11 Test: availability does not change with the active locale. See "availability does not depend on the active locale".
- [x] 4.12 Add letters-specific target times and star thresholds, deliberately loose. `starThresholdsLetters` (`app_constants.dart:33`) and the letters adaptive target of 1.5× the base (`app_constants.dart:91`). Test: "letters and Gorbov use looser targets than classic".

## 5. Home screen selector

- [x] 5.1 Decide the layout for four modes: 2×2 grid or wrapped chip row. Decided on a 2×2 grid of chips.
- [x] 5.2 Replace the two-segment toggle with that layout. `_buildModeToggle` (`lib/features/home/screens/home_screen.dart:243`) iterates `GameModes.all`.
- [x] 5.3 Read the grid size list from the selected mode instead of a global list. `AppConstants.gridSizesForMode(_selectedMode)` (`home_screen.dart:351`).
- [x] 5.4 Clamp the selected grid size into range when the mode changes. `_onModeTap` (`home_screen.dart:300-309`), the initial size (`home_screen.dart:41`) and the parent-fixed size (`home_screen.dart:70`).
- [x] 5.5 Test: switching from classic 9×9 to letters yields a valid size, not an empty grid. See `reverse_and_letters_test.dart` "classic 9x9 clamps into range when switching to letters" and `test/home/home_screen_test.dart` "parent fixed 9x9 / shows as 5x5 once letters is selected".
- [x] 5.6 Test: switching to Gorbov from a size below 5 yields a valid size. See "3x3 clamps up when switching to gorbov" and "every mode clamps every size to something it offers".

## 6. Integrate with progression

- [x] 6.1 Confirm records are stored under `reverse_{size}` and `letters_{size}` without overwriting classic. See `test/game/session_completion_test.dart` "a first result is a record under the {mode}_{size} key" (`letters_4` set, `classic_4` null) and "reverse and letters records survive an app restart".
- [x] 6.2 Confirm sessions record the correct mode string. `buildSessionFrom` copies `game.mode` (`game_provider.dart:258`). Tests: "a finished game is saved with its mode, size, time and coins" and `ordinal_tap_test.dart` "a session carries mode, size, total time with penalty and mistakes".
- [x] 6.3 Confirm coins, XP and streaks are awarded identically. `coinsForSession` takes no mode (`game_provider.dart:241`), XP is `gridSize²` (`lib/models/session.dart:25`), and `updateStreak` takes no mode (`session_completion_provider.dart:66`). The reverse session test asserts coins.
- [x] 6.4 Confirm achievements evaluate for the new modes. Achievements are mode-agnostic by design: `master_5x5` counts in any mode. Test: `test/progress/achievement_rules_test.dart` "master_5x5: 5x5 in 20 seconds or less, any mode".
- [x] 6.5 Make adaptive difficulty consult the mode's size list so it never suggests an unavailable size. `suggestNextGridSize` (`lib/features/home/providers/training_goals_provider.dart:19`) uses `gridSizesForMode(mode)` and a per-mode target. Tests: `test/home/training_goals_test.dart` "skips sizes the mode lacks and stops at its ceiling" and `home_screen_test.dart` "adaptive suggestion".
- [x] 6.6 Confirm leaderboard submission is unaffected or deliberately scoped to classic. It is deliberately scoped to classic: `_submitScores` posts a best time only when `session.mode == GameModes.classic` (`session_completion_provider.dart:95`). Weekly XP is posted for every mode. Test: "only classic records are posted to the Game Center time boards".

## 7. Localization

- [x] 7.1 Add mode names for reverse and letters to `app_ru.arb` and `app_en.arb`. `gameModeReverse` and `gameModeLetters` (`l10n/app_en.arb:388-389`).
- [x] 7.2 Add any in-game hint strings for the new modes. `gameMode*Hint` and `gameMode*Badge` are shown via `lib/features/game/game_mode_text.dart` under the home selector (`home_screen.dart:121`). The "find" badge uses `l10n.gameFind`.
- [x] 7.3 Verify ru and en key sets remain identical; regenerate localizations. CI ARB parity diff (`.github/workflows/ci.yml:40`). Each file has 11 `gameMode*` keys.

## 8. Verify and document

- [x] 8.1 Manual (CI): confirm `flutter analyze` is clean. It is gated in `.github/workflows/ci.yml` (9180bab). The latest PR run, 40211260997 on 10f3158, failed in 4 s with no steps executed, which is a runner or infra failure and not an analyzer result. Re-run it and confirm green. — done: `flutter analyze --fatal-infos` green on GitHub CI
- [x] 8.2 Manual (CI): confirm `flutter test` is green within the wall-clock budget, in the same CI re-run. All tests cited in this file exist, but this audit did not run them. — done: `flutter test` green on GitHub CI in 1m26s–2m30s
- [ ] 8.3 Manual (device): play reverse at 3×3 and 9×9, and letters at 3×3 and 5×5 in both ru and en. Check that the "find" badge shows N² first in reverse and a letter in letters, and that the grid hides while paused.
- [x] 8.4 Update `docs/plans/features/game-modes.md` to describe four modes. Done; it covers `processOrdinalTap`, `lettersGridSizes` and the `{mode}_{size}` records.
- [x] 8.5 Confirm the App Store description's claim of multiple modes is now accurate. `ios/fastlane/metadata/{ru,en-US}/description.txt:8` lists four modes.

## 9. Bug fixes found by the audit (done under this change)

- [x] 9.1 Reverse and letters records were lost on restart, so every result counted as a record (+25 coins) and slower times overwrote the best. `_loadRecords` now reads every Hive key (`lib/features/game/providers/records_provider.dart:37`, 5cbd984). Test: "reverse and letters records survive an app restart".
- [x] 9.2 A parent-fixed size or route param was not clamped per mode (letters 6×6+ crashed with `ArgumentError`, and Gorbov ran at 3×3). Now clamped in `initGame` (`game_provider.dart:288`) and `home_screen.dart:70`. Tests: `game_notifier_test.dart` "an unsupported size from the route is clamped to the mode" and `home_screen_test.dart` "parent fixed 9x9".
- [x] 9.3 The "find" badge showed the ordinal ("1" in reverse and letters). It now shows `GameState.expectedLabel` (`lib/models/game_state.dart:70`, `lib/features/game/widgets/game_header.dart:86`). Tests: the `ordinal_tap_test.dart` "expectedLabel" group.
- [x] 9.4 Records from every mode were posted to the classic Game Center time boards. Now classic-only (see 6.6).
- [x] 9.5 Hard-coded «Найдено», «Найди» and «сек» in the game UI are now localized (5cbd984).
- [x] 9.6 The mode hints were unused and are now shown under the selector (`home_screen.dart:121`).
- [x] 9.7 Mode string literals were replaced by `GameModes` (`lib/constants/game_modes.dart`). The selected mode persists under `lastSelectedModeKey` (`home_screen.dart:36,309`).
- [x] 9.8 Adaptive difficulty was described but not implemented. It is now implemented (b1391c2, see 6.5).
- [x] 9.9 Stats showed classic only. There is now a per-mode switcher, `ModeFilterChips` (`lib/features/progress/widgets/mode_filter.dart`), on the progress and parent screens, with per-mode records, charts and session badges (8a340da). Test: `test/progress/grid_stats_mode_test.dart`.
- [x] 9.10 The game kept running in the background. It now auto-pauses and hides the grid while paused (1e1e279). Test: `test/game/game_screen_pause_test.dart`.
