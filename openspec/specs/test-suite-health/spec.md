# test-suite-health Specification

## Purpose
TBD - created by archiving change test-suite-stabilization. Update Purpose after archive.

## Requirements

### Requirement: The test suite terminates within budget

`flutter test` SHALL run to completion and report a verdict. No test may hang until a timeout, and no test may wedge the runner. The suite SHALL fit the CI budget defined in `.github/workflows/ci.yml`: every test finishes under the per-test limit of `--timeout 60s`, and the whole `flutter` job (setup, analyze, test) finishes under `timeout-minutes: 10`.

#### Scenario: Full run completes

- **WHEN** `flutter test` is run from `brainy-app/`
- **THEN** it exits with a pass or fail verdict, and no test reports `TimeoutException`

#### Scenario: Per-test limit holds in CI

- **WHEN** the CI `Test` step runs `flutter test --reporter expanded --timeout 60s --coverage` on Flutter 3.47.6
- **THEN** no test exceeds 60 seconds

#### Scenario: Job fits its timeout

- **WHEN** the `flutter` job in `.github/workflows/ci.yml` runs
- **THEN** it finishes before `timeout-minutes: 10` is reached

#### Scenario: The runner shuts down cleanly

- **WHEN** the suite finishes
- **THEN** the output contains no `Bad state: Cannot close sink while adding stream` and no uncaught shutdown errors

### Requirement: Tests are order-independent

Every test SHALL produce the same result whether run alone or alongside its whole file. A test SHALL NOT leave focus, routes, platform channels, or pending storage operations that affect the next test.

#### Scenario: Isolated and full runs agree for the league tests

- **WHEN** each test in `brainy-app/test/features/league/league_screen_test.dart`, `league_edit_name_test.dart` and `league_edit_name_cancel_test.dart` is run alone with `--plain-name`, and then each whole file is run
- **THEN** the results are identical

#### Scenario: No test leaves a route open

- **WHEN** a test opens the league rename dialog or any other route
- **THEN** it closes that route (for example by tapping Cancel or Save and pumping the dismissal) before the test body ends

#### Scenario: No test leaves an input connection open

- **WHEN** a test enters text into a focused field
- **THEN** it releases focus while the field is still mounted, before the test body ends

#### Scenario: Rename-dialog tests stay under the known threshold

- **WHEN** a test that opens the league rename dialog is added
- **THEN** no single test file contains more than two tests that open that dialog, until the root cause of the deadlock documented in `design.md` is found

### Requirement: Hive I/O in widget tests does not stall the queue

A widget test SHALL NOT leave a Hive operation pending that a later test or teardown awaits. Hive data a widget test needs SHALL be seeded in `setUp`, outside the `testWidgets` fake-async zone. A UI-triggered Hive write whose completion the test or a later test depends on SHALL run inside `tester.runAsync`. A test file whose widgets start Hive writes from the fake-async zone SHALL NOT call `Hive.close()` in `tearDownAll`.

#### Scenario: Seeding happens outside fake async

- **WHEN** `brainy-app/test/home/home_screen_test.dart` needs sessions, progress or characters in Hive
- **THEN** it writes them from `setUp`, not from inside the `testWidgets` body

#### Scenario: UI-triggered writes run in real async

- **WHEN** a widget test triggers a Hive write through the UI and depends on it completing
- **THEN** the trigger and the wait run inside `tester.runAsync`

#### Scenario: No close that waits forever

- **WHEN** a widget test file lets widgets write to Hive from the fake-async zone
- **THEN** it does not call `Hive.close()` in `tearDownAll`

### Requirement: Waiting is bounded

Tests SHALL NOT wait on animations that never finish. `pumpAndSettle` SHALL NOT be used while a widget with a continuous animation — notably a focused `TextField` with its blinking cursor, or a `CircularProgressIndicator` — is on screen. Bounded `pump` calls SHALL be used instead.

#### Scenario: No unbounded settle around the rename dialog

- **WHEN** `brainy-app/test/features/league/league_edit_name_test.dart` and `league_edit_name_cancel_test.dart` are inspected
- **THEN** `pumpAndSettle` is called only before the rename dialog opens, and the dialog's open and dismissal transitions are driven by bounded `pump` calls

#### Scenario: No unbounded scroll search

- **WHEN** the files under `brainy-app/test/` are inspected
- **THEN** they contain no `scrollUntilVisible` call; `ensureVisible` is used to bring a known widget on screen

### Requirement: Every test file compiles

Every file under `brainy-app/test/` SHALL compile. A file that fails to load SHALL be treated as a failing test, not as an absence of tests.

#### Scenario: No load failures

- **WHEN** `flutter test` is run
- **THEN** no file is reported as failing at the `loading <path>` stage

#### Scenario: Previously broken files run in a full suite

- **WHEN** the full suite runs
- **THEN** `brainy-app/test/constants/app_constants_test.dart` and `brainy-app/test/home/mode_toggle_test.dart` execute their tests rather than failing to load

### Requirement: Test failures are diagnosable

When a test fails, the output SHALL identify the failure without requiring the suite to be re-run in a special mode.

#### Scenario: Progress output is not drowned out

- **WHEN** a test scrolls or retries internally
- **THEN** it does not emit thousands of repeated progress lines that bury the failure

#### Scenario: CI names each test

- **WHEN** the CI `Test` step runs
- **THEN** it uses `--reporter expanded`, so a hang or failure is attributable to a named test
