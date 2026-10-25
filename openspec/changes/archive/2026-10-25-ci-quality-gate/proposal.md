## Outcome (2026-10-25)

Implemented in the repo; enforcement on GitHub is still pending.

- `.github/workflows/ci.yml` runs on every pull request, on push to `main`, and as a reusable
  workflow (`workflow_call`). Job `Flutter analyze + test`: ARB key parity (ru vs en), Flutter
  pinned to `3.47.6`, `flutter analyze --fatal-infos`, `flutter test --timeout 60s --coverage`, a
  coverage artifact with no threshold, and a 10-minute job timeout. Job `Secret scan`: gitleaks
  8.30.1 over the full history with `.gitleaks.toml`.
- `deploy-testflight.yml` and `release.yml` call `ci.yml` as job `verify`, and the build job
  `needs: verify`. A red commit or tag never reaches TestFlight or the App Store.
- All three workflows declare `permissions: contents: read`. Concurrency is keyed on workflow and
  ref. Superseded runs are cancelled except on `main`.
- The Cloud Functions job is gone because `functions/` was deleted (`remove-monetization-go-free`).
- `CLAUDE.md` records that CI enforces these checks.
- External, not yet done: the first real run on GitHub (the branch is not pushed), making
  `Flutter analyze + test` a required check on `main`, and checking that a red PR cannot merge and
  a red `main` commit does not upload.

## Why

Before this change nothing verified the repository before it shipped. `deploy-testflight.yml` ran on push to `main` and went straight to building and uploading to TestFlight. No workflow ran `flutter analyze` or `flutter test`.

This was the root cause of most of the 2026-08-01 audit, not one finding among many. Commit `681dd86` shipped two tests that deadlock the runner. *(Historical:)* the RevenueCat migration left 11 analyzer errors and two test files that stopped compiling. Both reached `main` and then TestFlight because nothing checked them. Without this gate, the next commit can undo every other fix in the backlog.

## What Changes

- A `ci.yml` workflow runs on every pull request and every push to `main`, and can be called by other workflows.
- It checks ARB key parity and runs `flutter analyze --fatal-infos` and `flutter test`, so a missing translation key, an analyzer finding of any severity, or a failing test blocks the merge.
- It scans the full git history for secrets with gitleaks.
- It uploads a coverage report for visibility. No threshold is set.
- The Flutter version is pinned, and every job has a timeout.
- Workflow permissions are explicit and read-only.
- A newer push to the same branch cancels the superseded run. Runs on `main` are never cancelled.
- The Flutter job becomes a required status check on `main`, so merging cannot bypass the gate (External).
- TestFlight deployment and App Store release depend on the gate, so a red suite cannot ship.
- *(Historical, dropped:)* a Cloud Functions build/test job. `functions/` was deleted by `remove-monetization-go-free` before the job was needed.

## Capabilities

### New Capabilities
- `continuous-verification`: what must pass, on what trigger, before code merges or ships.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for CI. -->

## Impact

- `.github/workflows/ci.yml`: new, reusable.
- `.github/workflows/deploy-testflight.yml` and `.github/workflows/release.yml`: gain a `verify` job and `needs: verify`.
- `.gitleaks.toml`: new gitleaks config.
- `CLAUDE.md`: records the CI enforcement.
- GitHub branch protection on `main`: required status check `Flutter analyze + test` (External).
- CI minutes: two Ubuntu jobs per PR (`flutter`, `secrets-scan`). Neither needs macOS. A push to `main` also runs them again as the deploy's `verify` job.

Sequencing (done): the Flutter job could not pass until `revenuecat-removal-cleanup`, `share-card-record-key-fix` and `test-suite-stabilization` landed. The workflow was added first. It becomes required last.
