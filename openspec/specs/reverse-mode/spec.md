# reverse-mode Specification

## Purpose
TBD - created by archiving change reverse-and-letters-modes. Update Purpose after archive.

## Requirements

### Requirement: Reverse mode is played in descending order

Reverse mode SHALL present an N×N grid of the numbers 1 to N² in random positions, and SHALL require the player to tap them from N² down to 1. Each cell MUST store its position in the tap sequence (ordinal 1..N²) and display `N² − ordinal + 1`. Taps SHALL be validated by the same ordinal rule as classic and letters (`processOrdinalTap`).

#### Scenario: The highest number starts the sequence

- **WHEN** a 5×5 reverse session begins
- **THEN** the expected first tap is the cell showing 25

#### Scenario: A correct tap advances downward

- **WHEN** the expected number is 25 and the player taps 25
- **THEN** the cell is marked found and the expected number becomes 24

#### Scenario: An incorrect tap is penalised

- **WHEN** the expected number is 25 and the player taps 24
- **THEN** the mistake count increases by one, `AppConstants.mistakePenaltySeconds` is added to the penalty, the cell flashes as an error, and the expected number stays 25

#### Scenario: Tapping an already-found cell is ignored

- **WHEN** the player taps a cell that is already found
- **THEN** neither the state nor the mistake count changes

#### Scenario: The session completes at one

- **WHEN** the player taps 1 as the final number
- **THEN** the game status becomes finished and the timer stops

### Requirement: The "find" badge shows the displayed target

During a reverse session, the in-game "find" badge SHALL show the value drawn on the next target cell (`GameState.expectedLabel`), not its internal ordinal.

#### Scenario: Badge at the start

- **WHEN** a 4×4 reverse session begins
- **THEN** the badge shows 16, not 1

#### Scenario: Badge at the end

- **WHEN** fifteen correct taps have been made on a 4×4 reverse grid
- **THEN** the badge shows 1

### Requirement: Reverse mode is available at every grid size

Reverse mode SHALL be offered at every grid size the app supports (3, 4, 5, 6, 7, 9), with no unlock requirement.

#### Scenario: Every size is offered

- **WHEN** reverse mode is selected on the home screen
- **THEN** grid sizes 3, 4, 5, 6, 7 and 9 are all selectable

#### Scenario: A size from another mode is kept

- **WHEN** the player switches from classic 9×9 to reverse
- **THEN** the selected size stays 9×9

### Requirement: Reverse records persist per mode

A reverse personal best SHALL be stored under the `reverse_{size}` key. It MUST NOT overwrite the classic record, and it MUST survive an app restart. A result counts as a record only if it is strictly faster than the stored best.

#### Scenario: Records are kept separately from classic

- **WHEN** a reverse 5×5 session sets a personal best
- **THEN** it is stored under `reverse_5` and `classic_5` is unchanged

#### Scenario: Records survive a restart

- **WHEN** a reverse 5×5 record of 40 s exists and the app restarts
- **THEN** the record is still 40 s, and a later 55 s game is not a record and earns no record bonus

### Requirement: Reverse mode participates in progression

Reverse sessions SHALL be saved with mode `reverse`. They SHALL award the same coins (`coinsPerSession`, plus `coinsForRecord` on a record) and the same XP (`gridSize²`) as any mode, SHALL count toward the streak, and SHALL be evaluated by the same, mode-agnostic achievement rules.

#### Scenario: XP matches the grid size

- **WHEN** a reverse session on an N×N grid completes
- **THEN** it awards N² XP, the same as any other mode on that grid size

#### Scenario: Stars use the classic thresholds

- **WHEN** a reverse session completes
- **THEN** its star rating is derived from the classic `starThresholds` for that grid size

#### Scenario: Achievements are mode-agnostic

- **WHEN** a reverse 5×5 session completes in 20 s or less
- **THEN** `master_5x5` is unlocked, as it would be in classic

### Requirement: Reverse times are not posted to the classic time boards

Game Center time leaderboards are per grid size with no mode dimension. A reverse personal record MUST NOT be submitted to them. Weekly XP SHALL still be submitted.

#### Scenario: Reverse record

- **WHEN** a signed-in player sets a reverse 5×5 record
- **THEN** no best time is submitted, and the weekly XP total is submitted

### Requirement: Adaptive difficulty in reverse

Adaptive difficulty SHALL use the classic target time for reverse, and SHALL only consider reverse sessions at the current size.

#### Scenario: Suggestion after fast reverse games

- **WHEN** the last 5 reverse games at 7×7 average at or under the 7×7 target
- **THEN** the home screen suggests 9×9

#### Scenario: Classic games do not count

- **WHEN** only classic games at the current size meet the target
- **THEN** no suggestion is shown while reverse is selected
