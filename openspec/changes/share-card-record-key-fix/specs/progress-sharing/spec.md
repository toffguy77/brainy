## ADDED Requirements

### Requirement: The share card shows the player's real classic 5x5 best time

The shareable progress card SHALL display the current streak and the stored personal best for the classic 5x5 grid, looked up with the canonical key `recordKey(GameModes.classic, 5)`. The card SHALL report classic 5x5 only; records of other modes or grid sizes SHALL NOT substitute for it.

#### Scenario: A stored record is displayed

- **WHEN** the records map contains `classic_5` with value 22 and the locale is English
- **THEN** the card shows `22s` with the label `Best 5×5 result`

#### Scenario: Fresh install shows the empty state

- **WHEN** the records map is empty and the streak is 0
- **THEN** the card shows the streak stat and the title `Just getting started!`, omits the 5x5 stat, and renders without error

#### Scenario: Other modes or sizes do not stand in

- **WHEN** the records map contains `gorbov_5`, `reverse_5` and `classic_4` but no `classic_5`
- **THEN** the card omits the 5x5 stat and shows none of those values

### Requirement: The card is built through a single factory

The card SHALL be built by `ShareCard.fromState(progress, records, l10n)`. `ShareCard.showAndShare` SHALL obtain progress and records from their providers and build the card through this factory, and tests SHALL use the same factory, so the record lookup under test is the one that ships.

#### Scenario: Reverting the lookup fails the tests

- **WHEN** the lookup inside `ShareCard.fromState` stops resolving `classic_5`
- **THEN** the share card test for a stored record fails

### Requirement: Record lookups use the canonical key helper

Every consumer of the records map SHALL derive its key with `recordKey(mode, gridSize)`. No caller SHALL index the map with a raw integer or an inline key literal.

#### Scenario: No raw-key indexing of the records map

- **WHEN** `lib/` is searched for indexing of the records map
- **THEN** every call site passes a key produced by `recordKey`

#### Scenario: Type mismatches are caught by analysis

- **WHEN** CI runs `flutter analyze --fatal-infos`
- **THEN** it reports no `collection_methods_unrelated_type` finding and exits 0

### Requirement: Card text is localized

All card text SHALL come from ARB: the app name (`appName`), the plural streak title (`parentShareCardTitle`, with a distinct zero form), the 5x5 label (`parentShareBest5x5`) and the seconds unit (`shareSeconds`).

#### Scenario: Russian unit and plural

- **WHEN** the locale is Russian, `classic_5` is 22 and the streak is 3
- **THEN** the card shows `22 с` and `3 дня тренировок подряд!`

### Requirement: The card layout does not overflow

The card SHALL keep a fixed width of 340 logical pixels, and each stat SHALL take an equal share of the row, scaling long values down and wrapping labels to at most two lines.

#### Scenario: Large values and large text

- **WHEN** `classic_5` is 9999, the streak is 365, the locale is Russian and the text scale is 1.3
- **THEN** the card renders without an overflow exception and is 340 pixels wide

### Requirement: Sharing anchors to the button and reports failures

`ShareCard.showAndShare` SHALL receive the Share button's own context, render the card to a PNG, and open the system share sheet with `sharePositionOrigin` set to the button's on-screen rect, so the iPad popover anchors to the button. If rendering, writing the file or sharing throws, it SHALL show a SnackBar with `shareFailed` and SHALL NOT let the error escape.

#### Scenario: iPad popover anchor

- **WHEN** the parent taps Share in the dashboard AppBar on iPad
- **THEN** the share popover is anchored to the Share button

#### Scenario: Share failure

- **WHEN** capturing the image, writing the temporary file or opening the share sheet throws
- **THEN** a SnackBar shows the localized `shareFailed` message
