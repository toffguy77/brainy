## ADDED Requirements

### Requirement: Letters mode is played in alphabetical order

Letters mode SHALL present an N×N grid of distinct letters in random positions, and SHALL require the player to tap them in the alphabetical order of the active language.

#### Scenario: The first letter starts the sequence

- **WHEN** a 4×4 letters session begins in Russian
- **THEN** the expected first tap is «А»

#### Scenario: A correct tap advances the sequence

- **WHEN** the expected letter is «А» and the player taps «А»
- **THEN** the cell is marked found and the expected letter becomes «Б»

#### Scenario: An incorrect tap is penalised

- **WHEN** the expected letter is «А» and the player taps «В»
- **THEN** the mistake count increases, the configured time penalty is applied, and the expected letter stays «А»

#### Scenario: The session completes at the last letter

- **WHEN** the player taps the N²-th letter of the alphabet
- **THEN** the session is reported complete

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

Letters mode SHALL be offered only at grid sizes whose cell count does not exceed the shortest supported alphabet. With Russian at 33 letters and English at 26, this permits 3×3, 4×4 and 5×5 (25 cells) and excludes 6×6 and above.

The bound uses the shortest alphabet across all supported locales, not the active one, so that the set of available grid sizes does not change when the user switches language mid-progression.

#### Scenario: Only small grids are offered

- **WHEN** letters mode is selected on the home screen
- **THEN** grid sizes 3, 4 and 5 are selectable and 6, 7 and 9 are not offered

#### Scenario: Availability does not depend on the active language

- **WHEN** the app language is switched between Russian and English
- **THEN** the grid sizes offered for letters mode are unchanged

#### Scenario: An out-of-range size cannot start a session

- **WHEN** a letters session is requested at a grid size larger than the alphabet allows
- **THEN** the session does not start with a malformed grid

### Requirement: Letters follow the active language

The alphabet used SHALL be that of the app's active locale, so the exercise trains the alphabet the child actually reads.

#### Scenario: Russian uses the Russian alphabet

- **WHEN** the app locale is Russian
- **THEN** the grid is filled from the Russian alphabet beginning «А, Б, В…»

#### Scenario: English uses the Latin alphabet

- **WHEN** the app locale is English
- **THEN** the grid is filled from the Latin alphabet beginning A, B, C…

#### Scenario: Ambiguous letters are excluded from the Russian alphabet

- **WHEN** the Russian alphabet is used
- **THEN** «Ё» and «Й» are excluded, because they are visually confusable with «Е» and «И» at grid sizes and would make a mistap a matter of eyesight rather than sequencing

### Requirement: Letters mode participates in progression on equal terms

Letters sessions SHALL award coins and XP, count toward streaks and achievements, and record personal records under their own mode key.

#### Scenario: Records are kept separately

- **WHEN** a letters 5×5 session sets a personal best
- **THEN** it is stored under the `letters_5` record key and does not overwrite `classic_5`

#### Scenario: Adaptive difficulty respects the mode's ceiling

- **WHEN** adaptive difficulty would suggest a larger grid after strong letters results at 5×5
- **THEN** it does not suggest a size letters mode cannot offer
