## ADDED Requirements

### Requirement: Ordinal tap rules are covered for classic, reverse and letters

The pure tap rule `processOrdinalTap` SHALL have automated coverage, run for each of the classic,
reverse and letters modes, of correct, wrong, already-found and final taps. All three modes validate
the cell's ordinal against the expected ordinal; only the drawn label differs.

#### Scenario: A correct tap advances the sequence

- **WHEN** the player taps the cell holding the next expected ordinal
- **THEN** the cell is marked found, the expected ordinal advances and the game keeps playing

#### Scenario: A wrong tap applies the penalty

- **WHEN** the player taps a cell out of sequence
- **THEN** the mistake count increases by one, `AppConstants.mistakePenaltySeconds` is added, the cell is flagged as an error and not found, and the expected ordinal does not advance

#### Scenario: An already-found cell is ignored

- **WHEN** the player taps a cell that is already found
- **THEN** the tap is reported as already found and the state is unchanged

#### Scenario: The last ordinal finishes the game

- **WHEN** the player taps all N² ordinals of an N×N grid in order
- **THEN** the game is playing after every tap but the last, and finished after the last

#### Scenario: The reverse target badge counts down

- **WHEN** the expected label is read in reverse mode on a 4×4 grid
- **THEN** it is `16` at the start and `1` before the final tap

#### Scenario: The letters target badge shows a letter

- **WHEN** the expected label is read in letters mode
- **THEN** it is the alphabet letter (`A`, then `B`), not a digit

### Requirement: Gorbov tap rules are covered

The pure tap rule `processGorbovTap` SHALL have coverage of alternation between ascending white and
descending red numbers, of wrong taps, and of completion.

#### Scenario: Taps alternate white and red

- **WHEN** the player taps white 1, then the highest red, then white 2, then the next red
- **THEN** each tap is accepted, the white counter rises, the red counter falls and the expected colour alternates

#### Scenario: Wrong colour or wrong number is a mistake

- **WHEN** the player taps a red cell while white is expected, or a white cell with the wrong number
- **THEN** the mistake count increases and the penalty is applied

#### Scenario: An already-found Gorbov cell is not penalised

- **WHEN** the player taps a found cell
- **THEN** it is reported as already found and the mistake count is unchanged

#### Scenario: The full sequence completes the game

- **WHEN** every white and red number is tapped in the required order
- **THEN** the game reports completion

### Requirement: GameNotifier timing is covered with fake time

`GameNotifier` SHALL have coverage, under `fakeAsync`, of the behaviour that lives only in the
notifier: countdown, ticking, pause, finish, error flash, size clamping and timer disposal.

#### Scenario: Countdown then timer

- **WHEN** a game is initialised and 3 seconds elapse
- **THEN** the status moves from countdown to playing, and elapsed seconds then count one per second

#### Scenario: Pause stops the clock

- **WHEN** the game is paused and time passes, then resumed
- **THEN** elapsed seconds do not change while paused and resume counting afterwards

#### Scenario: Finishing stops the clock

- **WHEN** the last cell is tapped through `GameNotifier.tapCell`
- **THEN** the status is finished and elapsed seconds no longer change

#### Scenario: A wrong tap flashes, then clears

- **WHEN** a wrong cell is tapped
- **THEN** it is flagged as an error, the penalty is included in the total time, and the flag clears after the flash interval

#### Scenario: Untrusted sizes are clamped to the mode

- **WHEN** a game is initialised with 9×9 letters or 3×3 Gorbov
- **THEN** the grid is 5×5

#### Scenario: Disposal cancels timers

- **WHEN** the provider container is disposed mid-game
- **THEN** no periodic timer remains

### Requirement: Session completion is covered

`SessionCompleter.complete` SHALL have coverage, against real Hive boxes, of what a finished game
persists and reports.

#### Scenario: The session is saved

- **WHEN** a finished game is completed
- **THEN** a session is stored with its mode, grid size, duration, mistake count and coins, it heads `sessionsProvider`, the coins are credited and the next reminder is rescheduled

#### Scenario: Session duration includes penalties

- **WHEN** a session is built from a game with elapsed and penalty seconds
- **THEN** its duration is their sum and its coins are the per-session reward plus the record bonus when it is a record

#### Scenario: A first result is a record under its mode key

- **WHEN** the first game of a mode and size is completed
- **THEN** it is a record stored under `{mode}_{size}`, and no other mode's key is written

#### Scenario: A slower or equal time does not overwrite the record

- **WHEN** a game is completed slower than, or equal to, the stored record
- **THEN** it is not a record, earns no record bonus, and the stored record is unchanged

#### Scenario: Records of every mode survive a restart

- **WHEN** reverse and letters records are stored and a new container re-reads Hive
- **THEN** the records are returned and a slower game does not replace them

#### Scenario: Only classic records reach Game Center time boards

- **WHEN** records are set in reverse, letters, Gorbov and classic
- **THEN** only the classic time is submitted to the best-time board, while weekly XP is submitted for every game

#### Scenario: Achievement unlocks are reported once

- **WHEN** a first game is completed
- **THEN** the outcome lists `first_game` and `personal_record`
- **AND** a later game does not list `first_game` again

#### Scenario: Character unlocks are reported

- **WHEN** a game is completed at level 10
- **THEN** the outcome lists `zap` and the character is unlocked

### Requirement: Achievement rules are covered at their boundaries

The pure rule `achievementsToUnlock` SHALL have, for every shipped `AchievementId`, a test that the
achievement is granted when its condition holds and withheld on the other side of the boundary, and a
test that an already unlocked achievement is not granted again.

#### Scenario: Each condition unlocks at its boundary

- **WHEN** a session or progress value sits on each side of a rule's boundary (`first_game` with zero or one saved session; `personal_record` flag; `speed_demon` 3×3 at 5 vs 6 s; `master_5x5` 5×5 at 20 vs 21 s in any mode; `focus_mode` 0 vs 1 mistakes; streaks 2/3, 6/7, 29/30 days; `night_owl` 21:00 vs 22:00; `coin_hoarder` 499 vs 500 coins)
- **THEN** the achievement is granted on the qualifying side only

#### Scenario: An unlocked achievement is not re-awarded

- **WHEN** a condition holds for an achievement already in `unlockedAchievements`
- **THEN** it is not returned, while still-locked achievements that qualify are

#### Scenario: The catalogue is the authority

- **WHEN** the achievement catalogue is checked
- **THEN** every `AchievementId` has exactly one definition with a stable, unique persistence key

### Requirement: The reminder plan is covered

The pure decision `NotificationService.planReminder` SHALL have coverage of every branch, with `now`
injected. Platform delivery is out of scope.

#### Scenario: Disabled reminders schedule nothing

- **WHEN** reminders are disabled
- **THEN** no plan is returned

#### Scenario: Having played today schedules nothing

- **WHEN** the child has played today, even on a long streak
- **THEN** no plan is returned; a session at 00:01 today counts as today and one at 23:59 yesterday does not

#### Scenario: Not having played schedules at the default time

- **WHEN** reminders are enabled, no custom time is set and the child has not played today
- **THEN** a plan at the default reminder time is returned

#### Scenario: A custom time is honoured only when set

- **WHEN** a custom time is stored and the custom flag is set
- **THEN** the plan uses it; without the flag the default time is used

#### Scenario: The pool is chosen by streak

- **WHEN** the streak equals the threshold, or exceeds it by one
- **THEN** the motivational pool is used at the threshold and the streak-warning pool above it

#### Scenario: The variant is fixed per calendar day

- **WHEN** the variant index is computed for a date
- **THEN** it depends only on the calendar date, cycles through the pool, and is the same at 00:30 and 23:59 across a DST change

### Requirement: PIN lockout is covered with an injected clock

`PinLockout` SHALL have coverage of the attempt limit, the lockout duration, persistence, and reset on
success, with time supplied by an injected clock. `ParentNotifier` SHALL have coverage of setting and
verifying the PIN.

#### Scenario: Setting and verifying the PIN

- **WHEN** a PIN is set
- **THEN** a PIN is present, stored hashed, survives a new container, verifies when entered correctly, and is refused when wrong, absent or replaced

#### Scenario: Attempts below the limit do not lock

- **WHEN** one fewer wrong PIN than the limit is recorded
- **THEN** the lockout is not active and the attempts are counted

#### Scenario: Reaching the limit locks out

- **WHEN** the limit of wrong PINs is reached
- **THEN** the lockout is active for `AppConstants.parentLockoutSeconds` and the attempt count resets

#### Scenario: The lockout expires

- **WHEN** the clock reaches the lockout deadline
- **THEN** one second before it the lockout is active with 1 s remaining, and at it the lockout is over

#### Scenario: The lockout survives re-entry

- **WHEN** a new `PinLockout` is created over the same box during a lockout
- **THEN** it is still locked

#### Scenario: A correct PIN clears the count

- **WHEN** a correct PIN is recorded after failures
- **THEN** the attempt count is zero

### Requirement: Tests assert observable behaviour

Tests SHALL assert what a user or caller can observe, not internal structure. A test SHALL fail if
the behaviour it describes stops working; threshold rules SHALL be asserted on both sides of the
threshold.

#### Scenario: A test fails when its behaviour breaks

- **WHEN** the behaviour a test describes is deliberately broken or its condition inverted
- **THEN** that test fails

This requirement is grounded in audit findings — the `ShareCard` record lookup and the
reverse/letters records not reloaded after restart — where the code existed, compiled, and did the
wrong thing silently.

### Requirement: New tests preserve suite health

Tests added by this change SHALL satisfy the properties in `test-suite-health`: order-independent,
bounded waits, no hangs, and within the suite's wall-clock budget. Time-dependent code SHALL be tested
with `fakeAsync` or an injected clock, never real waits on the behaviour under test.

#### Scenario: The suite stays within budget

- **WHEN** the full suite runs after these additions
- **THEN** it completes within the established wall-clock budget

#### Scenario: New tests are order-independent

- **WHEN** each new test is run alone and as part of the full suite
- **THEN** the results are identical

#### Scenario: Coverage is visible without a threshold

- **WHEN** CI runs the suite
- **THEN** a coverage report is published as an artifact and no coverage threshold fails the build
