## ADDED Requirements

### Requirement: A configured time limit ends the session

When a parent has configured a maximum session time, a game session SHALL end once that duration of play has elapsed.

#### Scenario: The limit is reached

- **WHEN** the limit is 5 minutes and a session reaches 5 minutes of elapsed play
- **THEN** the game stops accepting taps and the session ends

#### Scenario: The limit is not reached

- **WHEN** the limit is 10 minutes and the child completes the table in 40 seconds
- **THEN** the session completes normally and the limit has no effect

#### Scenario: Unlimited means unlimited

- **WHEN** the limit is set to unlimited (0)
- **THEN** no session is ever ended by the limit

### Requirement: The countdown does not consume the limit

Elapsed play time SHALL be measured from the start of play, excluding the three-second countdown, so the limit measures playing rather than waiting.

#### Scenario: Countdown is excluded

- **WHEN** a session with a 5-minute limit begins
- **THEN** the limit is measured from the end of the countdown, not from screen entry

### Requirement: The child is told why the session ended

A session ended by the limit SHALL explain itself in language a 6-to-14-year-old understands. It SHALL NOT simply close or appear to be a crash.

#### Scenario: An explanation is shown

- **WHEN** a session ends because the limit was reached
- **THEN** the child sees a message stating that play time is over for now

#### Scenario: The message is localized

- **WHEN** the message is shown
- **THEN** it comes from the ARB files in the active locale, with no hardcoded text

#### Scenario: It is not framed as a failure

- **WHEN** the message is shown
- **THEN** it does not present the outcome as a loss or a mistake by the child

### Requirement: Progress up to the limit is preserved

Ending a session on the limit SHALL NOT discard what the child achieved. The partial session SHALL be recorded on the same terms as any other incomplete session.

#### Scenario: Coins and XP are kept

- **WHEN** a session ends on the limit after the child has made progress
- **THEN** the progress earned is retained rather than discarded

#### Scenario: A partial session sets no personal record

- **WHEN** a session ends on the limit without the table being completed
- **THEN** no personal record is written, because no completion time exists

### Requirement: The setting takes effect without a restart

A change to the limit SHALL apply to the next session started, with no app restart required.

#### Scenario: A new limit applies immediately

- **WHEN** a parent changes the limit and returns to the game
- **THEN** the next session uses the new value

#### Scenario: Changing the limit mid-session does not disrupt play

- **WHEN** the limit is changed while a session is in progress
- **THEN** the running session is not terminated abruptly by the new value

### Requirement: The setting is honest about what it does

The control SHALL either be enforced as described, or be removed. The app SHALL NOT present a parental control that has no effect.

#### Scenario: No unenforced control ships

- **WHEN** the parent settings screen is reviewed
- **THEN** every control on it changes observable app behaviour

#### Scenario: The plan matches the behaviour

- **WHEN** `docs/plans/features/parent-panel.md` is compared against the implementation
- **THEN** its description of the session time limit matches what the code does
