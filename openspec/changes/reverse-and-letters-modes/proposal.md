## Why

The App Store description promises "Несколько режимов игры: классический, обратный, буквенный" / "Multiple game modes: classic, reverse, letters". The app ships two modes, and neither of them is reverse or letters — it has classic and Gorbov-Schulte. The listing has been advertising two modes that do not exist.

Rather than correct the listing down, build what was promised. Both are established Schulte variants with real training value: reverse order exercises descending sequencing, and letters transfers the skill from digits to the alphabet, which is closer to the reading-speed benefit the app claims.

## What Changes

- **Reverse mode** — a Schulte table tapped in descending order, from N² down to 1. Available at every grid size.
- **Letters mode** — a grid of letters tapped in alphabetical order, in the app's active language. Available at 3×3, 4×4 and 5×5 only, because larger grids need more letters than either alphabet has.
- The home screen mode selector grows from a two-way toggle to four modes and is restructured accordingly.
- Records, sessions, achievements, adaptive difficulty and leaderboard submission all treat the new modes on the same terms as the existing ones.
- The App Store description keeps its claim of multiple modes and becomes accurate for the first time.

## Capabilities

### New Capabilities
- `reverse-mode`: descending-order Schulte play.
- `letters-mode`: alphabetical-order Schulte play, and the alphabet constraints that bound it.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability describing game modes. -->

## Impact

- `lib/models/game_state.dart` — cell content becomes a display string rather than an implied number; mode handling generalised.
- `lib/features/game/providers/game_provider.dart` — generation and tap validation for two new modes, as pure functions matching the Gorbov precedent.
- `lib/features/game/widgets/schulte_grid.dart` — renders letters as well as digits.
- `lib/features/home/screens/home_screen.dart` — the mode toggle becomes a four-way selector, with grid sizes filtered per mode.
- `lib/constants/app_constants.dart` — per-mode grid size lists, alphabets, star thresholds and target times for the new modes.
- `lib/features/game/providers/records_provider.dart` — no change needed; keys are already `{mode}_{size}`.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — mode names and hints.
- `docs/plans/features/game-modes.md` — describes four modes.
- `brainy-app/ios/fastlane/metadata/*/description.txt` — the claim becomes true.

Sequencing: after `remove-monetization-go-free`, so the new modes are built without any gating to thread through.
