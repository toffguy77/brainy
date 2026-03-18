# Premium Audit Fixes — Design Spec

> Fixes 4 issues found during premium offering audit: missing Gorbov-Schulte mode,
> misleading character text, ungated parent dashboard, and missing 9×9 in picker.

---

## 1. Gorbov-Schulte Mode (Premium)

### Overview

Gorbov-Schulte is an advanced Schulte table variant where the grid contains two sets of
numbers in different colors. The player alternates between them:
- **White numbers** — ascending: 1, 2, 3...
- **Red numbers** — descending: max, max-1, max-2...

Sequence: white 1 → red max → white 2 → red(max-1) → white 3 → red(max-2) → ...

### Available Grid Sizes

Gorbov mode is available for grid sizes ≥ 5: **5×5, 6×6, 7×7, 9×9**.

Number distribution for N×N grid:
- White numbers: `ceil(N²/2)` → values 1..ceil(N²/2)
- Red numbers: `floor(N²/2)` → values 1..floor(N²/2)
- Red numbers are tapped in descending order (max first)

Examples:
- 5×5 (25 cells): 13 white (1-13 ascending) + 12 red (12-1 descending)
- 7×7 (49 cells): 25 white (1-25 ascending) + 24 red (24-1 descending)

### Home Screen Changes

**New mode toggle** between character avatar and grid size picker:
- Segmented control: "Классика / Горбов"
- PRO badge on Gorbov button
- Tapping Gorbov without premium → `showPremiumBottomSheet()`
- When Gorbov selected: picker shows only sizes ≥ 5 (5×5, 6×6, 7×7, 9×9)
- When Classic selected: picker shows all sizes (3-9)

**Layout adjustments** to fit toggle on smallest screens (iPhone SE):
- Character avatar: 200px → 160px
- Spacer flex: 2 → 1
- Toggle height: ~40px

### Game State Changes

**`GridCell` model** — add `color` field:
```dart
class GridCell {
  final int number;
  final int row;
  final int col;
  final String color; // 'white' | 'red' (only used in gorbov mode)
  bool isFound;
  bool isError;
}
```

**`GameState`** — add tracking for alternating sequence:
- `nextWhiteNumber` — next expected white number (ascending)
- `nextRedNumber` — next expected red number (descending)
- `nextExpectedColor` — 'white' or 'red' (alternates on correct tap)
- `totalNumbers` in gorbov = N² (same as classic)
- `isCompleted` when all cells found

### Game Provider Changes

**`_generateGorbovGrid(int size)`:**
1. Calculate whiteCount = ceil(size²/2), redCount = floor(size²/2)
2. Generate white numbers 1..whiteCount, red numbers 1..redCount
3. Assign colors, shuffle positions
4. Return grid with colored cells

**`tapCell` in gorbov mode:**
1. Check cell.color matches nextExpectedColor
2. If white: check cell.number == nextWhiteNumber
3. If red: check cell.number == nextRedNumber
4. Correct → mark found, advance counter, switch expected color
5. Wrong color or wrong number → error animation + penalty

### UI Changes

**SchulteGrid** — render cells with color:
- White cells: current light text on dark background (unchanged)
- Red cells: red text (`AppColors.error` or similar warm red) on dark background
- Found cells: same green check as classic

**Progress bar** — show current expectation:
- "Find: white 3" / "Find: red 10" (localized)

**Game header** — show mode indicator (small "Gorbov" badge or bicolor icon)

### Session & Records

- Sessions saved with `mode: 'gorbov'`
- Records tracked separately per mode per grid size
- Parent dashboard shows gorbov sessions distinctly

---

## 2. Add 9×9 to Grid Picker

**`AppConstants.pickerGridSizes`:** `[3, 4, 5, 6, 7]` → `[3, 4, 5, 6, 7, 9]`

9 is already in `premiumGridSizes` so the lock icon appears automatically for free users.

Grid chip sizing may need adjustment for 6 items — verify they all fit in a row on
smallest screens. If tight, reduce chip width from 56 to 50px or use horizontal scroll.

---

## 3. Paywall Character Text

Change `paywallBenefit2` localization:
- EN: "5 unique characters" → "Exclusive character"
- RU: "5 уникальных персонажей" → "Эксклюзивный персонаж"

No logic changes — just string update in ARB files and generated localizations.

---

## 4. Parent Dashboard — Premium Gate

### Behavior

After PIN verification, check subscription status:
- **Premium:** show full dashboard (unchanged)
- **Free:** show premium gate screen instead of dashboard

### Premium Gate Screen

Full-screen upsell replacing the dashboard content:
- Blurred/dimmed preview of dashboard (or static illustration)
- Lock icon + "Parent Progress Panel"
- Subtitle: "Track your child's progress with detailed statistics"
- Button: "Unlock with Premium" → navigates to `/paywall`
- Back button returns to home

### Parent Settings

Settings screen (`/parent/settings`) remains accessible to ALL users — free and premium.
Only the dashboard (`/parent/dashboard`) is gated.

### Router Change

In `parent_dashboard_screen.dart` build method, wrap with premium check:
```dart
final isPremium = ref.watch(isPremiumProvider).value ?? false;
if (!isPremium) return _PremiumGateScreen();
// ... existing dashboard code
```

---

## 5. Tests

### Gorbov-Schulte Tests
- Grid generation: correct number distribution (white/red counts)
- Grid generation: all numbers present, no duplicates
- Tap logic: correct alternating sequence (white asc → red desc)
- Tap logic: wrong color → error
- Tap logic: right color, wrong number → error
- Game completion detection
- Session saved with mode 'gorbov'

### 9×9 Picker Test
- 9×9 appears in picker grid sizes
- 9×9 requires premium (lock shown for free users)

### Paywall Text Test
- Verify paywallBenefit2 returns updated string

### Parent Dashboard Gate Tests
- Free user sees premium gate screen after PIN
- Premium user sees full dashboard after PIN
- Settings accessible for both free and premium users

---

## Files to Create/Modify

### New Files
- None expected — all changes fit in existing files

### Modified Files
- `lib/constants/app_constants.dart` — pickerGridSizes, gorbov grid sizes
- `lib/models/game_state.dart` — GridCell color, gorbov tracking fields
- `lib/features/game/providers/game_provider.dart` — gorbov grid gen, tap logic
- `lib/features/game/widgets/schulte_grid.dart` — colored cell rendering
- `lib/features/game/widgets/game_header.dart` — mode indicator
- `lib/features/home/screens/home_screen.dart` — mode toggle, layout adjustments
- `lib/features/parent/screens/parent_dashboard_screen.dart` — premium gate
- `lib/features/subscription/screens/paywall_screen.dart` — benefit text (if hardcoded)
- `lib/l10n/app_en.arb` — paywallBenefit2, gorbov strings
- `lib/l10n/app_ru.arb` — paywallBenefit2, gorbov strings
- `lib/l10n/app_localizations_en.dart` — generated
- `lib/l10n/app_localizations_ru.dart` — generated
- `test/` — new test files for gorbov logic, premium gates
