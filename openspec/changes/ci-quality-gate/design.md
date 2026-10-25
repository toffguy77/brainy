## Context

Three workflows exist: `deploy-testflight.yml` (push to `main`, path-filtered, builds and uploads to TestFlight), `release.yml` (tag `v*`, full App Store pipeline) and `monitor.yml` (daily cron checking App Store review status). None runs a test or a linter.

The audit found the consequences rather than the cause first: 11 analyzer errors, two test files that fail to compile, two tests that deadlock the runner, a 20-minute suite. Every one of those reached `main` and TestFlight. The absence of a gate is why the repository could drift this far without anyone noticing.

Constraint: the deploy workflow needs macOS and Xcode. Verification does not — analysis and unit tests run on Ubuntu, which is roughly ten times cheaper per minute and starts faster.

## Goals / Non-Goals

**Goals:**
- Analysis and tests run automatically on every change.
- A failure blocks merging and blocks deployment.
- Feedback is fast enough that developers wait for it.

**Non-Goals:**
- Running `integration_test/screenshot_test.dart` in CI. It needs a simulator, making it slow and macOS-bound; screenshot generation is a release-time activity, not a per-PR one.
- Building the iOS app on every PR. A full macOS archive per PR is expensive and largely redundant with the analyzer.
- Coverage thresholds. Meaningless until `test-coverage-expansion` establishes a baseline, and premature thresholds invite tests written to satisfy a number.
- Secret scanning. Proposed as a follow-up in `secrets-hygiene`.

## Decisions

**`--fatal-infos`, not plain `analyze`.** The strongest argument is empirical: the `ShareCard` bug — `records[5]` against a `Map<String, int>`, so the share card never showed a result — was reported only as an info. A gate that ignores infos would have let it through, exactly as the absence of any gate did. The cost is that the baseline must be spotless first, which is what `revenuecat-removal-cleanup` and `share-card-record-key-fix` deliver.

*Alternative considered:* start with errors-only and tighten later. Rejected — "tighten later" is what did not happen with the analyzer for the entire life of this repository.

**Ubuntu, not macOS, for verification.** Neither analysis nor unit tests need Xcode. Ten times cheaper and faster to start.

**Separate `flutter` and `functions` jobs.** They fail for unrelated reasons and have different toolchains, so a Node failure should not mask a Dart failure. The `functions` job is short-lived — `remove-monetization-go-free` deletes the package — and the spec records that its removal is part of that change rather than an oversight here.

**Add the workflow before making it required.** The suite is currently red. Adding the workflow immediately makes the failures visible on every PR without blocking work; requiring it only after the three prerequisite changes land avoids a period where nothing can merge. The sequencing is the delicate part of this change, not the YAML.

**Gate deployment on the checks, not just merging.** Branch protection stops a PR merging, but `deploy-testflight.yml` fires on push to `main` and a direct push bypasses PR protection entirely. Both paths need covering.

**No untrusted input in the workflow.** All steps use fixed commands; nothing interpolates `github.event.*` into a `run:` block, so there is no injection surface.

## Risks / Trade-offs

- **A required check with a red suite blocks all work** → Sequence strictly: add workflow → land the three prerequisites → make required. This ordering is the main risk in the change.
- **`--fatal-infos` fails on a future Flutter SDK's new lints** → Real: `flutter-action` with `channel: stable` can move under the project. Accepted for now; pin the version if it causes churn.
- **Twenty-minute suite makes CI unusable** → Blocked on `test-suite-stabilization`, which sets a three-minute budget.
- **PRs from forks cannot read secrets** → Neither verification job needs secrets, so fork PRs are fully verifiable.
- **`functions` job deleted along with the package** → Guarded by an explicit scenario in the spec, so it is a planned removal rather than a silent one.

## Migration Plan

1. Add `ci.yml`. It will fail — that is the point; the failures are the audit findings made visible.
2. Land `revenuecat-removal-cleanup` → analyzer errors gone.
3. Land `share-card-record-key-fix` → last analyzer info gone, `--fatal-infos` passes.
4. Land `test-suite-stabilization` → suite green and fast.
5. Enable the required status check on `main`.
6. Add the dependency from `deploy-testflight.yml` on the gate.

**Rollback:** delete the workflow and remove the required check. No production impact — CI is purely additive until step 5.

## Open Questions

- Should `deploy-testflight.yml` depend on the gate via `workflow_run`, or should verification be inlined as a job the deploy job `needs:`? `workflow_run` keeps the workflows separate but is awkward with path filters; inlining duplicates the job. Needs a decision when step 6 is implemented.
- Pin the Flutter version rather than tracking `stable`?
- Add a required check for the `functions` job before it is deleted, or skip it given the package's short remaining life?
