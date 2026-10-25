## ADDED Requirements

### Requirement: Every change is verified before it merges

Static analysis and the test suite SHALL run on every pull request and on every push to `main`.

#### Scenario: Pull request triggers verification

- **WHEN** a pull request is opened or updated against any branch
- **THEN** the CI workflow runs `flutter analyze --fatal-infos` and `flutter test`

#### Scenario: Direct push to main triggers verification

- **WHEN** a commit is pushed directly to `main`
- **THEN** the same checks run

#### Scenario: A failing check blocks the merge

- **WHEN** analysis or tests fail on a pull request
- **THEN** the pull request cannot be merged until they pass

### Requirement: Analyzer findings of any severity fail the build

CI SHALL treat analyzer infos as failures, so that a real defect reported at info severity cannot be dismissed as noise.

#### Scenario: An info-level finding fails CI

- **WHEN** a change introduces a finding that `flutter analyze` reports at info severity
- **THEN** the CI job exits non-zero

This requirement is grounded in a concrete case: the `ShareCard` record-lookup bug — a feature that silently never worked — was reported by the analyzer only as `collection_methods_unrelated_type`, an info.

### Requirement: Cloud Functions are verified while they exist

While the `functions/` package exists, CI SHALL build and test it.

#### Scenario: Functions are built and tested

- **WHEN** CI runs and `functions/` is present
- **THEN** `npm ci`, `npm run build` and `npm test` all succeed

#### Scenario: The job is removed with the package

- **WHEN** `functions/` is deleted by `remove-monetization-go-free`
- **THEN** the `functions` job is removed from the workflow in the same change

### Requirement: Deployment depends on verification

A build SHALL NOT reach TestFlight from a commit whose checks did not pass.

#### Scenario: Red main does not deploy

- **WHEN** a commit lands on `main` with failing checks
- **THEN** the TestFlight deployment does not run

#### Scenario: Green main deploys

- **WHEN** a commit lands on `main` with passing checks and touches a deploy-relevant path
- **THEN** the TestFlight deployment proceeds

### Requirement: The gate cannot be bypassed

The Flutter verification job SHALL be a required status check on `main`.

#### Scenario: Required check is configured

- **WHEN** branch protection for `main` is inspected
- **THEN** the Flutter CI job is listed as a required status check

### Requirement: CI is not spent on superseded commits

Concurrent runs for the same branch SHALL be cancelled when a newer commit supersedes them.

#### Scenario: A newer push cancels the older run

- **WHEN** two commits are pushed to the same branch in quick succession
- **THEN** the run for the older commit is cancelled

### Requirement: CI feedback is fast enough to be used

The verification workflow SHALL complete quickly enough that developers wait for it rather than merge around it.

#### Scenario: Verification completes promptly

- **WHEN** the CI workflow runs on a typical change
- **THEN** it completes in under ten minutes

This depends on `test-suite-stabilization`: the suite currently takes twenty minutes because two tests deadlock.
