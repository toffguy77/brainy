## ADDED Requirements

### Requirement: The test suite terminates

`flutter test` SHALL run to completion and report a verdict. No test may hang until a timeout, and no test may wedge the runner.

#### Scenario: Full run completes

- **WHEN** `flutter test` is run from `brainy-app/`
- **THEN** it exits with a pass or fail verdict, and no test reports `TimeoutException`

#### Scenario: Run is fast enough to gate a deploy

- **WHEN** `flutter test` is run on a clean checkout
- **THEN** it completes in under three minutes

#### Scenario: The runner shuts down cleanly

- **WHEN** the suite finishes
- **THEN** the output contains no `Bad state: Cannot close sink while adding stream` and no uncaught shutdown errors

### Requirement: Tests are order-independent

Every test SHALL produce the same result whether run alone or alongside its whole file. A test SHALL NOT leave focus, routes, platform channels, or storage state that affects the next test.

This requirement exists because the defect being fixed is exactly an order dependency: each league screen test passes alone in under a second, but from the seventh consecutive test the isolate deadlocks.

#### Scenario: Isolated and full runs agree

- **WHEN** each test in `test/features/league/league_screen_test.dart` is run alone with `--plain-name` and then the whole file is run
- **THEN** the results are identical

#### Scenario: No test leaves a route open

- **WHEN** a test opens a dialog or pushes a route
- **THEN** it closes that route before the test body ends

#### Scenario: No test leaves an input connection open

- **WHEN** a test interacts with a focused text field
- **THEN** focus is released before the test body ends

### Requirement: Waiting is bounded

Tests SHALL NOT wait on animations that never finish. `pumpAndSettle` SHALL NOT be used while a widget with a continuous animation — notably a focused `TextField` with its blinking cursor, or a `CircularProgressIndicator` — is on screen. Bounded `pump` calls SHALL be used instead.

#### Scenario: No unbounded settle around a focused field

- **WHEN** `test/features/league/league_screen_test.dart` is inspected
- **THEN** no `pumpAndSettle` call occurs while the rename dialog's autofocused text field is mounted

#### Scenario: No unbounded scroll search

- **WHEN** the test suite is inspected
- **THEN** no `scrollUntilVisible` call can loop indefinitely when its target is already visible or absent

### Requirement: Every test file compiles

Every file under `test/` SHALL compile. A file that fails to load SHALL be treated as a failing test, not as an absence of tests.

#### Scenario: No load failures

- **WHEN** `flutter test` is run
- **THEN** no file is reported as failing at the `loading <path>` stage

#### Scenario: Previously broken files run in a full suite

- **WHEN** the full suite runs
- **THEN** `test/constants/app_constants_test.dart` and `test/home/mode_toggle_test.dart` execute their tests rather than failing to load

### Requirement: Test failures are diagnosable

When a test fails, the output SHALL identify the failure without requiring the suite to be re-run in a special mode.

#### Scenario: Progress output is not drowned out

- **WHEN** a test scrolls or retries internally
- **THEN** it does not emit thousands of repeated progress lines that bury the failure
