## ADDED Requirements

### Requirement: Reverse mode is played in descending order

Reverse mode SHALL present an N×N grid of the numbers 1 to N² in random positions, and SHALL require the player to tap them from N² down to 1.

#### Scenario: The highest number starts the sequence

- **WHEN** a 5×5 reverse session begins
- **THEN** the expected first tap is 25

#### Scenario: A correct tap advances downward

- **WHEN** the expected number is 25 and the player taps 25
- **THEN** the cell is marked found and the expected number becomes 24

#### Scenario: An incorrect tap is penalised

- **WHEN** the expected number is 25 and the player taps 24
- **THEN** the mistake count increases, the configured time penalty is applied, and the expected number stays 25

#### Scenario: The session completes at one

- **WHEN** the player taps 1 as the final number
- **THEN** the session is reported complete

### Requirement: Reverse mode is available at every grid size

Reverse mode SHALL be offered at all grid sizes the app supports, with no unlock requirement.

#### Scenario: Every size is offered

- **WHEN** reverse mode is selected on the home screen
- **THEN** grid sizes 3, 4, 5, 6, 7 and 9 are all selectable

### Requirement: Reverse mode participates in progression on equal terms

Reverse sessions SHALL award coins and XP, count toward streaks and achievements, and record personal records under their own mode key.

#### Scenario: Records are kept separately from classic

- **WHEN** a reverse 5×5 session sets a personal best
- **THEN** it is stored under the `reverse_5` record key and does not overwrite `classic_5`

#### Scenario: XP matches the grid size

- **WHEN** a reverse session on an N×N grid completes
- **THEN** it awards the same XP as any other mode on that grid size

#### Scenario: Stars are awarded

- **WHEN** a reverse session completes
- **THEN** a star rating is derived from thresholds defined for reverse mode at that grid size
