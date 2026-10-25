## 1. Make the game loop safe to refactor

- [x] 1.1 Confirm `remove-monetization-go-free` has landed so no gating threads through the new modes
- [x] 1.2 Add `GameNotifier` tests covering classic and Gorbov before touching shared code (coordinate with `test-coverage-expansion`)
- [x] 1.3 Record the baseline: analyze clean, suite green

## 2. Generalise the grid model

- [x] 2.1 Change `GridCell` to carry a display string plus an ordinal position in the target sequence
- [x] 2.2 Update classic generation and validation to the ordinal model
- [x] 2.3 Keep Gorbov on its own two-sequence logic
- [x] 2.4 Update `schulte_grid.dart` to render the display string rather than a number
- [x] 2.5 Confirm classic and Gorbov tests stay green

## 3. Reverse mode

- [x] 3.1 Add `generateReverseGrid` as a pure function
- [x] 3.2 Add `processReverseTap` as a pure function
- [x] 3.3 Test: first expected tap is N²
- [x] 3.4 Test: a correct tap advances downward
- [ ] 3.5 Test: an incorrect tap penalises and does not advance
- [x] 3.6 Test: completion at 1
- [x] 3.7 Reuse classic target times and star thresholds

## 4. Letters mode

- [x] 4.1 Add Russian and Latin alphabets to `AppConstants`, excluding «Ё» and «Й»
- [x] 4.2 Add `generateLettersGrid` as a pure function using a contiguous alphabet prefix
- [ ] 4.3 Add `processLettersTap` as a pure function
- [x] 4.4 Bound available sizes to 3, 4 and 5 using the shortest supported alphabet
- [x] 4.5 Test: first expected tap is the first letter
- [x] 4.6 Test: every letter on the grid is distinct
- [x] 4.7 Test: a 3×3 English grid contains exactly A–I
- [x] 4.8 Test: positions are randomised while the letter set is fixed
- [ ] 4.9 Test: an incorrect tap penalises and does not advance
- [x] 4.10 Test: completion at the N²-th letter
- [x] 4.11 Test: availability does not change with the active locale
- [x] 4.12 Add letters-specific target times and star thresholds, deliberately loose

## 5. Home screen selector

- [x] 5.1 Decide the layout for four modes: 2×2 grid or wrapped chip row
- [x] 5.2 Replace the two-segment toggle with that layout
- [x] 5.3 Read the grid size list from the selected mode instead of a global list
- [x] 5.4 Clamp the selected grid size into range when the mode changes
- [x] 5.5 Test: switching from classic 9×9 to letters yields a valid size, not an empty grid
- [x] 5.6 Test: switching to Gorbov from a size below 5 yields a valid size

## 6. Integrate with progression

- [x] 6.1 Confirm records are stored under `reverse_{size}` and `letters_{size}` without overwriting classic
- [x] 6.2 Confirm sessions record the correct mode string
- [x] 6.3 Confirm coins, XP and streaks are awarded identically
- [ ] 6.4 Confirm achievements evaluate for the new modes
- [ ] 6.5 Make adaptive difficulty consult the mode's size list so it never suggests an unavailable size
- [ ] 6.6 Confirm leaderboard submission is unaffected or deliberately scoped to classic

## 7. Localization

- [x] 7.1 Add mode names for reverse and letters to `app_ru.arb` and `app_en.arb`
- [x] 7.2 Add any in-game hint strings for the new modes
- [x] 7.3 Verify ru and en key sets remain identical; regenerate localizations

## 8. Verify and document

- [x] 8.1 `flutter analyze` clean
- [x] 8.2 `flutter test` green and within the suite's wall-clock budget
- [ ] 8.3 Play each new mode manually at its smallest and largest allowed size
- [x] 8.4 Update `docs/plans/features/game-modes.md` to describe four modes
- [x] 8.5 Confirm the App Store description's claim of multiple modes is now accurate
