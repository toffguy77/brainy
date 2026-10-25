## ADDED Requirements

### Requirement: No personal or child-identifying data is collected

Analytics events SHALL NOT carry personal data. No event or parameter SHALL contain a name, an age, free text entered by a user, a device identifier, or any value that could identify a child.

This constraint outranks every measurement goal in this specification. Where the two conflict, the event is dropped.

#### Scenario: The child's custom name is never sent

- **WHEN** a player sets a custom display name
- **THEN** no analytics event contains that name

#### Scenario: Age is sent only as a bucket, if at all

- **WHEN** onboarding completion is recorded
- **THEN** any age information is the coarse bucket already collected (`6-9`, `10-12`, `13-14`) and never a precise age or birth date

#### Scenario: No free text is ever a parameter

- **WHEN** the event definitions are reviewed
- **THEN** every parameter is an enum, a bounded number, or a fixed string from a known set

#### Scenario: Parameters are audited before release

- **WHEN** a new event is added
- **THEN** its parameters are reviewed against this requirement before it ships

### Requirement: Events are defined as constants

Event and parameter names SHALL be declared as constants in one place. Call sites SHALL NOT pass string literals.

#### Scenario: No literal event names at call sites

- **WHEN** the codebase is searched for analytics calls
- **THEN** every call references a declared constant

#### Scenario: A typo cannot create a silent second event

- **WHEN** an event name is misspelled at a call site
- **THEN** compilation fails rather than silently emitting an unknown event

### Requirement: The core engagement funnel is measured

The app SHALL record the events needed to understand acquisition, activation and retention, given that it is free and has no revenue signal.

#### Scenario: Onboarding completion is recorded

- **WHEN** a user finishes onboarding
- **THEN** an event records completion with the selected goals, frequency and age bucket

#### Scenario: Session completion is recorded

- **WHEN** a game session finishes
- **THEN** an event records grid size, mode, duration, mistake count and stars earned

#### Scenario: Personal records are recorded

- **WHEN** a session sets a personal record
- **THEN** an event records the grid size and mode

#### Scenario: Streak milestones are recorded

- **WHEN** a streak reaches a milestone
- **THEN** an event records the streak length

#### Scenario: Achievement unlocks are recorded

- **WHEN** an achievement unlocks
- **THEN** an event records its identifier

#### Scenario: Character and accessory activity is recorded

- **WHEN** a character is selected or an accessory is purchased
- **THEN** an event records the identifier and, for a purchase, the coin price

### Requirement: Analytics failures never affect the app

Analytics SHALL be non-blocking and failure-tolerant. A logging error SHALL NOT interrupt gameplay or surface to the user.

#### Scenario: A logging failure is swallowed

- **WHEN** an analytics call throws
- **THEN** the app continues normally and the user sees nothing

#### Scenario: Analytics never blocks a transition

- **WHEN** an event is logged during a screen transition
- **THEN** the transition is not delayed waiting for it

### Requirement: Analytics are disabled in tests and debug builds

Test and debug runs SHALL NOT emit analytics, so development traffic does not pollute production data.

#### Scenario: No events during tests

- **WHEN** the test suite runs
- **THEN** no analytics event reaches Firebase

### Requirement: The privacy declaration matches reality

Published privacy labels SHALL describe what the app actually collects — no more and no less.

#### Scenario: Declaration matches the implemented event set

- **WHEN** the App Store privacy labels are compared against the implemented events
- **THEN** every declared category corresponds to data actually collected, and nothing collected is undeclared

#### Scenario: Collecting nothing means declaring nothing

- **WHEN** the owner decides not to collect analytics
- **THEN** the dependency, the router observer and the Analytics privacy declaration are all removed together
