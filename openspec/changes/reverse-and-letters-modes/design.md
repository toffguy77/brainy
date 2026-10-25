## Context

The store listing claims three modes; the app has two, and neither matches the claim. Rather than shrink the listing, the decision is to build reverse and letters.

The existing code makes this cheaper than it looks. Records are already keyed `{mode}_{gridSize}`, with a migration for the legacy numeric format, so a new mode needs no storage work. `GameSession` already carries a `mode` string. Gorbov-Schulte established the pattern for a second mode: grid generation and tap validation extracted as pure functions (`generateGorbovGrid`, `processGorbovTap`) precisely so they could be unit-tested, and those tests are among the few genuinely valuable ones in the suite.

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
- Reworking the results or statistics screens; they are already mode-agnostic.

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

- **Generalising `GridCell` touches the shared game loop, which has no test coverage** → The largest risk in this change. Mitigate by landing `test-coverage-expansion`'s `GameNotifier` tests first, or by writing them as part of this change. Refactoring an untested core game loop for a new feature is how regressions reach production.
- **Switching mode with an incompatible size selected** → Explicit rule: on mode switch, clamp the selected size into the new mode's allowed range. Needs a test; it is the obvious source of a crash or an empty grid.
- **Letters star thresholds guessed wrong** → Ship deliberately loose and tighten later. A 5×5 letters table is materially harder than 5×5 classic.
- **Adaptive difficulty suggests a size letters cannot offer** → The suggestion logic must consult the mode's size list, not the global one.
- **Four modes crowd the home screen** → A real design cost of the decision, accepted.
- **Russian «Ъ», «Ь», «Ы» are awkward as standalone letters for young children** → They sit at positions 28–30 and are never reached within a 25-cell bound, so the issue does not arise in practice.

## Migration Plan

1. Ensure `GameNotifier` has test coverage before refactoring it.
2. Generalise `GridCell` to display string plus ordinal; keep classic and Gorbov green throughout.
3. Add `generateReverseGrid` and `processReverseTap` as pure functions, with tests.
4. Add `generateLettersGrid` and `processLettersTap` as pure functions, with tests, including alphabet bounds.
5. Add per-mode grid size lists, alphabets, target times and star thresholds to `AppConstants`.
6. Restructure the home screen selector; implement size clamping on mode switch.
7. Add mode names and hints to both ARB files.
8. Verify records, sessions, achievements, adaptive difficulty and leaderboard submission for both modes.
9. Update `game-modes.md`; confirm the store description is now accurate.

**Rollback:** the modes are additive. Removing them from the selector disables them without touching stored records, though any records already set under the new keys would become unreachable rather than lost.

## Open Questions

- What are the right star thresholds and target times for letters mode? Needs playtesting; ship loose.
- Should reverse mode be offered for Gorbov-Schulte too (descending white, ascending red)? Deliberately out of scope.
- Should the letters alphabet be configurable by a parent, for a child learning a third language?
- Does the home screen selector become a 2×2 grid or a wrapped chip row? A design call to make before implementing step 6.
