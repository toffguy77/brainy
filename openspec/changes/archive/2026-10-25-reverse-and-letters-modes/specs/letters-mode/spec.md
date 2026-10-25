## ADDED Requirements

### Requirement: Letters mode is played in alphabetical order

Letters mode SHALL present an N×N grid of distinct letters in random positions, and SHALL require the player to tap them in the alphabetical order of the active language. Each cell MUST store its alphabet position as its ordinal, and taps SHALL be validated by the shared ordinal rule (`processOrdinalTap`).

#### Scenario: The first letter starts the sequence

- **WHEN** a 4×4 letters session begins in Russian
- **THEN** the expected first tap is «А»

#### Scenario: A correct tap advances the sequence

- **WHEN** the expected letter is «А» and the player taps «А»
- **THEN** the cell is marked found and the expected letter becomes «Б»

#### Scenario: An incorrect tap is penalised

- **WHEN** the expected letter is «А» and the player taps «В»
- **THEN** the mistake count increases by one, `AppConstants.mistakePenaltySeconds` is added to the penalty, and the expected letter stays «А»

#### Scenario: The session completes at the last letter

- **WHEN** the player taps the N²-th letter of the alphabet
- **THEN** the game status becomes finished and the timer stops

### Requirement: The "find" badge shows the letter

During a letters session, the "find" badge SHALL show the letter drawn on the next target cell (`GameState.expectedLabel`), never a digit.

#### Scenario: Badge advances by letter

- **WHEN** a 3×3 English letters session begins and the player taps «A»
- **THEN** the badge shows «A» before the tap and «B» after it

### Requirement: The grid uses a contiguous prefix of the alphabet

The grid SHALL contain the first N² letters of the active alphabet, each exactly once, so the target sequence is unambiguous and every letter on screen is reachable.

#### Scenario: No letter is repeated

- **WHEN** a letters grid is generated
- **THEN** every letter on the grid is distinct

#### Scenario: The grid is a prefix, not a random sample

- **WHEN** a 3×3 letters grid is generated in English
- **THEN** it contains exactly A through I

#### Scenario: Positions are randomised

- **WHEN** two letters grids of the same size are generated
- **THEN** their letter positions differ, while their letter sets are identical

### Requirement: Letters mode is bounded by alphabet length

Letters mode SHALL be offered only at 3×3, 4×4 and 5×5 (`AppConstants.lettersGridSizes`). The ceiling is set by the shortest supported alphabet: English has 26 letters and Russian 31 once «Ё» and «Й» are removed. The bound MUST NOT depend on the active language.

#### Scenario: Only small grids are offered

- **WHEN** letters mode is selected on the home screen
- **THEN** grid sizes 3, 4 and 5 are selectable, and 6, 7 and 9 are not offered

#### Scenario: Availability does not depend on the active language

- **WHEN** the app language is switched between Russian and English
- **THEN** the grid sizes offered for letters are unchanged, and every offered size generates in both alphabets

#### Scenario: Grid generation rejects an oversize grid

- **WHEN** `generateLettersGrid` is called with more cells than the alphabet has
- **THEN** it throws `ArgumentError` rather than building a malformed grid

### Requirement: Grid sizes are clamped into the letters range

Every grid size that enters letters mode SHALL be clamped to the nearest size letters offers (`AppConstants.clampGridSizeForMode`). This covers the picker selection on a mode switch, the persisted last size, a parent-fixed size, and the `/game` route parameter. A letters session MUST never start at a size above 5×5.

#### Scenario: Switching from a large classic grid

- **WHEN** classic 9×9 is selected and the player switches to letters
- **THEN** the selected size becomes 5×5

#### Scenario: Parent-fixed size above the ceiling

- **WHEN** a parent has fixed the size at 9×9 and the player selects letters
- **THEN** the home screen shows 5×5, and Play starts a 5×5 letters session

#### Scenario: Untrusted route parameter

- **WHEN** `/game?size=9&mode=letters` is opened
- **THEN** `GameNotifier.initGame` starts a 5×5 letters session instead of throwing

### Requirement: Letters follow the active language

The alphabet SHALL be that of the app's active locale: Russian for `ru` and Latin for any other locale.

#### Scenario: Russian uses the Russian alphabet

- **WHEN** the app locale is Russian
- **THEN** the grid is filled from the Russian alphabet beginning «А, Б, В…»

#### Scenario: English uses the Latin alphabet

- **WHEN** the app locale is English
- **THEN** the grid is filled from the Latin alphabet beginning A, B, C…

#### Scenario: Ambiguous letters are excluded from the Russian alphabet

- **WHEN** the Russian alphabet is used
- **THEN** «Ё» and «Й» are excluded, because at grid sizes they are visually confusable with «Е» and «И»

### Requirement: Letters records persist per mode

A letters personal best SHALL be stored under the `letters_{size}` key. It MUST NOT overwrite the record of any other mode, and it MUST survive an app restart. The key does not include the locale.

#### Scenario: Records are kept separately

- **WHEN** a letters 4×4 session sets a first result of 30 s
- **THEN** `letters_4` is 30 and `classic_4` is unset

#### Scenario: Records survive a restart

- **WHEN** a letters 3×3 record of 15 s exists and the app restarts
- **THEN** the record is still 15 s

### Requirement: Letters mode participates in progression

Letters sessions SHALL be saved with mode `letters`. They SHALL award the same coins and XP (`gridSize²`) as any mode, SHALL count toward the streak, and SHALL be evaluated by the mode-agnostic achievement rules. Stars SHALL use the looser `starThresholdsLetters`.

#### Scenario: Letters stars are looser than digits

- **WHEN** a 5×5 letters session completes in 33 s
- **THEN** it earns three stars, while the same time in classic 5×5 earns two

#### Scenario: Achievements count in letters

- **WHEN** a letters 5×5 session completes in 20 s or less
- **THEN** `master_5x5` is unlocked

### Requirement: Letters times are not posted to the classic time boards

A letters personal record MUST NOT be submitted to the Game Center time leaderboards, because those boards have no mode dimension. Weekly XP SHALL still be submitted.

#### Scenario: Letters record

- **WHEN** a signed-in player sets a letters 5×5 record
- **THEN** no best time is submitted

### Requirement: Adaptive difficulty respects the letters ceiling

Adaptive difficulty SHALL suggest only sizes from the letters size list. It SHALL use a target of 1.5× the digit target time, and SHALL only consider letters sessions at the current size.

#### Scenario: No suggestion past 5×5

- **WHEN** the last 5 letters games at 5×5 average at or under the letters target
- **THEN** no larger size is suggested

#### Scenario: Suggestion inside the range

- **WHEN** the last 5 letters games at 4×4 average at or under the letters 4×4 target
- **THEN** 5×5 is suggested
