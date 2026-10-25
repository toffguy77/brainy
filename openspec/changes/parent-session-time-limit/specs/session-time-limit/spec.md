## ADDED Requirements

### Requirement: The app has no play-time limit

The app SHALL NOT limit how long or how often a child plays. No game session SHALL be ended, blocked or shortened because of elapsed play time.

#### Scenario: A long play streak is never cut off

- **WHEN** a child plays session after session for longer than 15 minutes in one day
- **THEN** every session runs until the child completes or leaves it, and no "time is up" message is shown

#### Scenario: The daily goal is not a cap

- **WHEN** today's play time reaches or exceeds the daily goal
- **THEN** the home screen marks the goal as done and the child can keep starting new sessions

### Requirement: No session-time control is offered or documented

The parent settings screen SHALL NOT offer a maximum session time or play-time limit control. The codebase SHALL NOT keep the constant, provider field, setter or localized strings for one. The feature plans SHALL NOT describe one.

#### Scenario: The settings screen has no limit control

- **WHEN** a parent opens `/parent/settings`
- **THEN** no control for maximum session time or play-time limit is shown

#### Scenario: No code or strings remain

- **WHEN** `brainy-app/lib`, `brainy-app/test`, `brainy-app/integration_test` and `brainy-app/l10n` are searched for `maxSessionTime`, `parentMaxSessionTime` or `sessionTime`
- **THEN** there are no matches

#### Scenario: The plan matches the code

- **WHEN** the settings section of `docs/plans/features/parent-panel.md` is read
- **THEN** it lists no session time limit

#### Scenario: A leftover stored value is inert

- **WHEN** an upgraded device still has a value stored under the old `parentMaxSessionTime` key
- **THEN** the app ignores it and behaves exactly as on a fresh install

### Requirement: Every parent-settings control changes observable behaviour

Every control on the parent settings screen SHALL have an effect the parent or child can observe. A control that only stores a value nobody reads SHALL NOT ship.

#### Scenario: Grid size auto mode

- **WHEN** the parent selects "auto"
- **THEN** the child can pick any size valid for the selected mode on the home screen, and the home screen suggests the next size once recent games meet the target

#### Scenario: Grid size fixed mode

- **WHEN** the parent selects "fixed" and a size such as 9x9
- **THEN** the home screen shows only that size, offers no size suggestion, and starts the game at that size

#### Scenario: Fixed size is clamped to the mode

- **WHEN** the fixed size is 9x9 and the child selects the letters mode
- **THEN** the home screen shows and starts 5x5, the largest size letters supports

#### Scenario: Daily goal

- **WHEN** the parent changes the daily goal to 5, 10 or 15 minutes
- **THEN** the home screen bar shows "Today: X of N min" with the new N, and the dashboard uses the same goal

#### Scenario: Sounds off

- **WHEN** the parent turns sounds off
- **THEN** no game sound effects play on taps, game start, completion or achievements

#### Scenario: Haptics off

- **WHEN** the parent turns haptics off
- **THEN** no haptic feedback fires on taps or game completion

#### Scenario: Notifications on with permission granted

- **WHEN** the parent turns notifications on and iOS grants permission
- **THEN** the toggle stays on and a daily reminder is scheduled, unless the child already played today

#### Scenario: Notifications on with permission denied

- **WHEN** the parent turns notifications on and iOS denies permission
- **THEN** the toggle stays off and a message tells the parent to allow notifications in iOS Settings

#### Scenario: Notifications off

- **WHEN** the parent turns notifications off
- **THEN** any scheduled reminder is cancelled

#### Scenario: Reminder time

- **WHEN** the parent picks a reminder time, or resets it to the default
- **THEN** the reminder is rescheduled for that time, or for the default time

#### Scenario: Change PIN

- **WHEN** the parent taps "Change PIN"
- **THEN** the PIN screen opens in change mode and the new PIN replaces the old one

#### Scenario: Legal links

- **WHEN** the parent taps the privacy policy or terms link
- **THEN** the page for the current language opens in the system browser

#### Scenario: Version label

- **WHEN** the parent taps the app version label
- **THEN** the version string is copied to the clipboard and a confirmation is shown
