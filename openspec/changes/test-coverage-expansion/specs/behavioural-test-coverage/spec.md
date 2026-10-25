## ADDED Requirements

### Requirement: The core game loop is covered

`GameNotifier` SHALL have automated coverage of tap handling, penalties, completion and persistence, for both Classic and Gorbov-Schulte modes.

#### Scenario: A correct tap advances the sequence

- **WHEN** the player taps the next expected number
- **THEN** the cell is marked found and the expected number advances

#### Scenario: An incorrect tap applies the penalty

- **WHEN** the player taps a number out of sequence
- **THEN** the mistake count increases and the configured time penalty is applied

#### Scenario: Classic mode completes at the last number

- **WHEN** the player taps the final number of an N×N classic grid in order
- **THEN** the game reports completion

#### Scenario: Gorbov mode alternates colours

- **WHEN** the player taps white and red numbers in the required alternating order
- **THEN** each tap is accepted and completion is reported only when both sequences are exhausted

#### Scenario: A completed session is persisted

- **WHEN** a session completes
- **THEN** a session is written with grid size, duration, mistake count, mode and coins earned

#### Scenario: A personal record is written when beaten

- **WHEN** a session completes faster than the stored record for that mode and size
- **THEN** the record is updated under the correct `{mode}_{size}` key

### Requirement: Notification rescheduling is covered

`NotificationService.reschedule()` SHALL have coverage of every branch.

#### Scenario: Disabled notifications cancel

- **WHEN** reschedule runs with notifications disabled
- **THEN** any pending notification is cancelled and none is scheduled

#### Scenario: Having played today cancels

- **WHEN** reschedule runs and the child has already played today
- **THEN** no notification is scheduled

#### Scenario: Not having played schedules

- **WHEN** reschedule runs, notifications are enabled, and the child has not played today
- **THEN** a notification is scheduled

#### Scenario: Custom time is honoured

- **WHEN** a custom reminder time is set
- **THEN** the notification is scheduled for that time rather than the default

#### Scenario: Text pool is chosen by streak

- **WHEN** the current streak exceeds the threshold
- **THEN** the streak-warning pool is used rather than the motivational pool

### Requirement: Achievement conditions are covered

Every shipped achievement SHALL have a test asserting it unlocks when its condition is met, and that it is not awarded twice.

#### Scenario: Each condition unlocks its achievement

- **WHEN** the condition for a given achievement is satisfied
- **THEN** that achievement unlocks

#### Scenario: An unlocked achievement is not re-awarded

- **WHEN** the condition is satisfied again after the achievement is already unlocked
- **THEN** no duplicate unlock is recorded

### Requirement: PIN protection is covered

`ParentPinScreen` SHALL have coverage of setting, verification, and the lockout behaviour that protects the parent area.

#### Scenario: First entry sets the PIN

- **WHEN** no PIN is stored and a four-digit PIN is entered
- **THEN** it is stored and access is granted

#### Scenario: A correct PIN verifies

- **WHEN** the stored PIN is entered
- **THEN** access is granted

#### Scenario: A wrong PIN is refused

- **WHEN** an incorrect PIN is entered
- **THEN** access is refused and the attempt is counted

#### Scenario: Exceeding the attempt limit locks out

- **WHEN** the configured number of failed attempts is reached
- **THEN** further attempts are refused for the lockout duration

#### Scenario: The lockout expires

- **WHEN** the lockout duration has passed
- **THEN** attempts are accepted again

### Requirement: Tests assert observable behaviour

Tests SHALL assert what a user or caller can observe, not internal structure. A test SHALL fail if the behaviour it describes stops working.

#### Scenario: A test fails when its behaviour breaks

- **WHEN** the behaviour a test describes is deliberately broken
- **THEN** that test fails

This requirement is grounded in two audit findings — the `ShareCard` record lookup and the unenforced session time limit — where the code existed, compiled, and did nothing.

### Requirement: New tests preserve suite health

Tests added by this change SHALL satisfy the properties in `test-suite-health`: order-independent, bounded waits, no hangs, and within the suite's wall-clock budget.

#### Scenario: The suite stays within budget

- **WHEN** the full suite runs after these additions
- **THEN** it completes within the established wall-clock budget

#### Scenario: New tests are order-independent

- **WHEN** each new test is run alone and as part of the full suite
- **THEN** the results are identical
