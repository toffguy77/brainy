## Why

Nothing verifies this repository before it ships. `deploy-testflight.yml` triggers on push to `main` and goes straight to building and uploading to TestFlight. No workflow runs `flutter analyze`, `flutter test`, or the Cloud Functions tests.

This is the root cause of most of the 2026-08-01 audit, not one finding among many. Commit `681dd86` shipped two tests that deadlock the runner; the RevenueCat migration left 11 analyzer errors and two test files that stopped compiling. Both reached `main` and then TestFlight, because nothing looked. Every other fix in this backlog is undone by the next commit unless this gate exists.

## What Changes

- A `ci.yml` workflow runs on every pull request and every push to `main`.
- It runs `flutter analyze --fatal-infos` and `flutter test`, so a red analyzer or a failing test blocks the merge.
- It runs the Cloud Functions build and tests while `functions/` still exists.
- Runs are cancelled when superseded by a newer push to the same branch, so CI minutes are not spent on stale commits.
- The Flutter job becomes a required status check on `main`, so the gate cannot be bypassed by merging.
- Deployment is made to depend on the gate, so a red suite cannot reach TestFlight.

## Capabilities

### New Capabilities
- `continuous-verification`: what must pass, on what trigger, before code merges or ships.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for CI. -->

## Impact

- `.github/workflows/ci.yml` — new.
- `.github/workflows/deploy-testflight.yml` — gains a dependency on the gate.
- GitHub branch protection on `main` — required status check added.
- CI minutes: two Ubuntu jobs per PR. Both are cheap; neither needs macOS, unlike the deploy workflow.

Sequencing: the Flutter job cannot pass until `revenuecat-removal-cleanup` (11 analyzer errors), `share-card-record-key-fix` (the last analyzer info) and `test-suite-stabilization` (the deadlock) have landed. The workflow can be added first and made required last. The `functions` job is deleted by `remove-monetization-go-free`.
