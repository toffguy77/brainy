## Decision / Outcome (2026-10-25)

Implemented as designed, with the corrections below. The evidence is listed per task in `tasks.md`.

- **One validation rule for three modes.** `GridCell.number` is the ordinal and `label` is what is drawn. A single pure `processOrdinalTap` (`game_provider.dart:153`) validates classic, reverse and letters, while Gorbov keeps `processGorbovTap`. The separate `processReverseTap` and `processLettersTap` named in the Migration Plan were deliberately not written, because they would duplicate `processOrdinalTap`.
- **The badge reads the drawn label, not the ordinal.** `GameState.expectedLabel` (`game_state.dart:70`) shows N² first in reverse and a letter in letters. The first build showed the raw ordinal ("1").
- **Records needed a storage fix.** The claim below that "a new mode needs no storage work" was wrong. `_loadRecords` iterated a fixed `classic`/`gorbov` list, so reverse/letters records were dropped after a restart. That made every result a record (+25 coins) and let slower times overwrite the best. It now loads every non-legacy key (`records_provider.dart:37`).
- **Size clamping is applied wherever a size enters.** That covers the picker, the mode switch, the persisted size, the parent-fixed size (`home_screen.dart:70`) and untrusted route params (`GameNotifier.initGame`, `game_provider.dart:288`). Before the fix, a parent-fixed 7×7 crashed letters with `ArgumentError` and Gorbov ran at 3×3.
- **Leaderboards.** Game Center time boards have no mode dimension, so only classic best times are submitted. Weekly XP covers every mode.
- **Achievements** are mode-agnostic by design.
- **Statistics were not "already mode-agnostic".** They showed classic only. A per-mode switcher (`ModeFilterChips`) with per-mode records, charts and session badges was added (8a340da).
- **Adaptive difficulty was not "existing code".** It was described in the plans but not implemented. It was built in this change (`training_goals_provider.dart`, b1391c2). A suggestion needs 5 recent games at the current size and mode with an average at or under the mode's target: base for classic and reverse, ×1.5 for letters, ×2 for Gorbov. It only offers the next size in the mode's own list, so letters stops at 5×5. It is hidden while the parent fixes the size.

## Context

The store listing claims three modes; the app has two, and neither matches the claim. Rather than shrink the listing, the decision is to build reverse and letters.

The existing code makes this cheaper than it looks. Records are already keyed `{mode}_{gridSize}`, with a migration for the legacy numeric format. *(Correction: loading still enumerated only classic and Gorbov keys and had to be changed. See Outcome.)* `GameSession` already carries a `mode` string. Gorbov-Schulte established the pattern for a second mode: grid generation and tap validation extracted as pure functions (`generateGorbovGrid`, `processGorbovTap`) precisely so they could be unit-tested, and those tests are among the few genuinely valuable ones in the suite.

The obstacle is `GridCell`, which models a number. Letters mode needs cells that display a character. The cleanest resolution is for cells to carry a display string plus an ordinal position in the target sequence — which subsumes numbers, reversed numbers and letters uniformly.

## Goals / Non-Goals

**Goals:**
- Two working modes that match what the store already advertises.
- Both integrated into records, sessions, progression and adaptive difficulty on the same terms as existing modes.
- Generation and validation as pure, unit-tested functions, following the Gorbov precedent.

**Non-Goals:**
- A general mode plug-in architecture. Four concrete modes do not justify one, and speculative generality is how this codebase accumulated the debt the audit found.
- A letters variant of Gorbov (two-colour alphabetical). Combinatorially possible, not obviously valuable.
- Localised alphabets beyond the two supported languages.
- Reworking the results screen. *(Correction: the statistics screens were **not** mode-agnostic, because they showed classic only. A per-mode switcher was added; see Outcome.)*

## Decisions

**Generalise `GridCell` to a display string plus a sequence ordinal.** Classic is ordinal *i* showing "*i*"; reverse is ordinal *i* showing "N²−*i*+1"; letters is ordinal *i* showing the *i*-th letter. One validation rule — "is this the next ordinal?" — then serves three modes, and Gorbov keeps its own two-sequence logic.

*Alternative considered:* a separate `LetterCell` type. Rejected — it forces a union type through the widget layer for no gain.

**Bound letters mode by the shortest supported alphabet, not the active one.** Russian has 33 letters, English 26, so the active-alphabet rule would offer 5×5 in both but would make availability locale-dependent as soon as a third language appeared. Worse, a child who set a 5×5 letters record and then switched language could find the mode's shape changing under them. A fixed bound of 25 cells is stable and explainable.

**Exclude «Ё» and «Й» from the Russian alphabet.** At grid cell sizes, «Ё»/«Е» and «Й»/«И» differ by a diacritic a few pixels tall. Including them turns mistaps into an eyesight test rather than a sequencing test, which is not what the exercise trains. This leaves 31 usable Russian letters — still far above the 25 the bound allows, so it costs nothing.

*Alternative considered:* keep the full alphabet for correctness. Rejected — the app is for 6-to-14-year-olds and the penalty for a mistap is a time penalty; making that hinge on diacritic discrimination is a poor trade.

**Use a contiguous prefix of the alphabet, not a random sample.** A random sample would make the target sequence depend on which letters happened to be drawn, so the player could not know what comes next without scanning the whole grid. A prefix means the sequence is always A, B, C… which is what "alphabetical order" means to a child.

**Reuse classic's target times and star thresholds for reverse; give letters its own.** Reverse is the same visual search with a different traversal, so its difficulty is close to classic. Letters is genuinely slower — recognising a letter is a different lookup from recognising a digit, and children read digits faster — so reusing classic's thresholds would make three stars unreachable. Letters thresholds need calibration; starting looser and tightening on real data is the safer direction.

**Restructure the home screen selector rather than extend the toggle.** The current control is a two-segment toggle. Four modes do not fit that shape at the app's font sizes. A wrapped row of four chips, or a 2×2 grid, is required — the exact layout is a design decision, but the two-segment toggle cannot survive.

**Filter grid sizes by mode.** Gorbov already excludes sizes below 5; letters excludes above 5. The picker must read its size list from the selected mode rather than from a single global list, and must correct the selected size when a mode switch makes it invalid.

## Risks / Trade-offs

- **Generalising `GridCell` touches the shared game loop, which has no test coverage** → The largest risk in this change. Mitigate by landing `test-coverage-expansion`'s `GameNotifier` tests first, or by writing them as part of this change. *(Done: `test/game/game_notifier_test.dart` and `ordinal_tap_test.dart`.)*
- **Switching mode with an incompatible size selected** → Explicit rule: on mode switch, clamp the selected size into the new mode's allowed range. Needs a test; it is the obvious source of a crash or an empty grid.
- **Letters star thresholds guessed wrong** → Ship deliberately loose and tighten later. A 5×5 letters table is materially harder than 5×5 classic.
- **Adaptive difficulty suggests a size letters cannot offer** → Adaptive difficulty did not exist yet. It was built with `gridSizesForMode(mode)` as its ceiling (`training_goals_provider.dart:19`), and is tested by "skips sizes the mode lacks and stops at its ceiling".
- **Four modes crowd the home screen** → A real design cost of the decision, accepted.
- **Russian «Ъ», «Ь», «Ы» are awkward as standalone letters for young children** → They sit at positions 26–28 of `alphabetRu` (after removing «Ё» and «Й»), past the 25-cell bound, so they are never reached in practice.

## Migration Plan

1. Ensure `GameNotifier` has test coverage before refactoring it.
2. Generalise `GridCell` to display string plus ordinal; keep classic and Gorbov green throughout.
3. Add `generateReverseGrid` as a pure function, with tests. Validation goes through the shared `processOrdinalTap`.
4. Add `generateLettersGrid` as a pure function, with tests, including alphabet bounds. Validation goes through `processOrdinalTap`.
5. Add per-mode grid size lists, alphabets, target times and star thresholds to `AppConstants`.
6. Restructure the home screen selector; implement size clamping on mode switch.
7. Add mode names and hints to both ARB files.
8. Verify records, sessions, achievements, adaptive difficulty and leaderboard submission for both modes.
9. Update `game-modes.md`; confirm the store description is now accurate.

**Rollback:** the modes are additive. Removing them from the selector disables them without touching stored records, though any records already set under the new keys would become unreachable rather than lost.

## Open Questions (answered)

- **Letters star thresholds and target times?** They shipped loose: `starThresholdsLetters` is about 1.5× the digit thresholds, and the adaptive target is 1.5× the base. Tighten them once real play data exists. Gorbov's adaptive target is 2× the base.
- **Reverse Gorbov (descending white, ascending red)?** Out of scope and not built.
- **Parent-configurable letters alphabet?** Not built. The alphabet follows the app locale (`Localizations.localeOf(context)` → `alphabetFor`, with English for anything but `ru`).
- **2×2 grid or wrapped chip row?** A 2×2 grid of chips (`home_screen.dart:243`), with the mode's rule hint underneath.
