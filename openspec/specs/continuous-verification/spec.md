# continuous-verification Specification

## Purpose
TBD - created by archiving change ci-quality-gate. Update Purpose after archive.

## Requirements

### Requirement: Every change is verified before it merges

The CI workflow SHALL run on every pull request and on every push to `main`. Its `Flutter analyze + test` job SHALL check ARB key parity between `app_ru.arb` and `app_en.arb`, then run `flutter analyze --fatal-infos` and `flutter test`.

#### Scenario: Pull request triggers verification

- **WHEN** a pull request is opened or updated against any branch
- **THEN** the CI workflow runs the ARB parity check, `flutter analyze --fatal-infos` and `flutter test`

#### Scenario: Direct push to main triggers verification

- **WHEN** a commit is pushed directly to `main`
- **THEN** the same checks run

#### Scenario: ARB keys diverge

- **WHEN** a key, other than `@@`-prefixed metadata, exists in one of `brainy-app/l10n/app_ru.arb` and `brainy-app/l10n/app_en.arb` but not the other
- **THEN** the parity step prints the difference and the job fails

### Requirement: Analyzer findings of any severity fail the build

CI MUST treat analyzer infos as failures, so that a real defect reported at info severity cannot be dismissed as noise.

#### Scenario: An info-level finding fails CI

- **WHEN** a change introduces a finding that `flutter analyze` reports at info severity
- **THEN** the CI job exits non-zero

This requirement comes from a concrete case: the `ShareCard` record-lookup bug was a feature that never worked, and the analyzer reported it only as `collection_methods_unrelated_type`, an info.

### Requirement: The repository is scanned for secrets

CI SHALL run gitleaks over the full git history with the repository's `.gitleaks.toml`. A finding SHALL fail the `Secret scan` job. Only public client identifiers MAY be allowlisted, and the config MUST explain why they are not secrets.

#### Scenario: A committed secret fails the scan

- **WHEN** any commit in the history adds a value matching a gitleaks rule that is not allowlisted
- **THEN** the `Secret scan` job fails, with the value redacted in the log

#### Scenario: Public Firebase config is not reported

- **WHEN** the scan meets the Firebase API key in `brainy-app/lib/firebase_options.dart` or `brainy-app/ios/Runner/GoogleService-Info.plist`
- **THEN** it is not reported, because those keys ship in every build and are restricted in Google Cloud instead

### Requirement: Shipping depends on verification

The TestFlight deploy and the App Store release MUST NOT build from a commit whose verification did not pass. Both workflows SHALL call the CI workflow as a `verify` job, and their build job SHALL declare `needs: verify`.

#### Scenario: Red main does not deploy

- **WHEN** a commit lands on `main`, touches a deploy-relevant path, and analysis, tests, ARB parity or the secret scan fail
- **THEN** the TestFlight `deploy` job does not run

#### Scenario: Green main deploys

- **WHEN** a commit lands on `main` with passing checks and touches a deploy-relevant path
- **THEN** the TestFlight deployment proceeds on the same commit that was verified

#### Scenario: Red tag does not release

- **WHEN** a `v*` tag is pushed and its verification fails
- **THEN** the App Store `release` job does not run

### Requirement: The gate cannot be bypassed

The `Flutter analyze + test` job SHALL be a required status check on `main`.

#### Scenario: Required check is configured

- **WHEN** branch protection for `main` is inspected
- **THEN** `Flutter analyze + test` is listed as a required status check

#### Scenario: A failing check blocks the merge

- **WHEN** analysis or tests fail on a pull request into `main`
- **THEN** the pull request cannot be merged until they pass

### Requirement: Builds are reproducible and least-privileged

Every workflow that runs Flutter SHALL pin the same Flutter version (currently `3.47.6`). Every workflow SHALL declare explicit `permissions`, with read-only `contents` unless a job needs more.

#### Scenario: A new stable Flutter release ships

- **WHEN** a new Flutter version is published on the stable channel
- **THEN** CI, deploy and release keep using the pinned version until it is changed on purpose

#### Scenario: Permissions are inspected

- **WHEN** `ci.yml`, `deploy-testflight.yml` or `release.yml` is inspected
- **THEN** it declares `permissions: contents: read`

### Requirement: CI is not spent on superseded commits, except on main

Concurrent runs of the same workflow on the same ref SHALL be cancelled when a newer commit supersedes them. Runs on `main` MUST NOT be cancelled. A gate run started by deploy or release MUST NOT cancel the standalone CI run on the same ref.

#### Scenario: A newer push to a branch cancels the older run

- **WHEN** two commits are pushed to the same non-`main` branch in quick succession
- **THEN** the run for the older commit is cancelled

#### Scenario: Pushes to main all finish

- **WHEN** two commits are pushed to `main` in quick succession
- **THEN** both verification runs complete

### Requirement: CI feedback is fast and bounded

The verification job SHALL complete in under ten minutes and SHALL be stopped if it runs longer. A single hung test MUST NOT consume the whole budget.

#### Scenario: Verification exceeds the budget

- **WHEN** the `Flutter analyze + test` job runs longer than 10 minutes
- **THEN** it is cancelled and reported as failed

#### Scenario: A test hangs

- **WHEN** a single test runs longer than 60 seconds
- **THEN** that test fails and the suite continues

### Requirement: Coverage is visible but not enforced

CI SHALL upload the test coverage report (`lcov.info`) as an artifact on every run. CI MUST NOT fail on a coverage threshold.

#### Scenario: Coverage report is available

- **WHEN** the test step finishes, whether it passed or failed
- **THEN** a `coverage-lcov` artifact is uploaded if the report exists, and no coverage percentage gates the job
