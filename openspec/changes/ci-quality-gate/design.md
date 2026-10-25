## Decision (2026-10-25)

- **Gate wiring: reusable workflow + `needs:`, not `workflow_run`.** `ci.yml` declares
  `workflow_call` (`ci.yml:9`). `deploy-testflight.yml:23-27` and `release.yml:16-20` call it as
  job `verify`, and the build job `needs: verify`. Why:
  - `workflow_run` fires on *completion*, so it needs an `if: conclusion == 'success'` guard.
  - It runs the default-branch copy of the triggered workflow and checks out a different SHA by
    default, so the build and the verified commit can differ.
  - It does not respect the deploy workflow's `paths:` filter.
  - It would not cover `release.yml` (tag pushes) without a second wiring.

  `needs: verify` keeps verification and build on the same SHA, in the same run, shown as one
  graph in the UI. It covers both deploy and release, and it duplicates no YAML. `needs` waits on
  the whole called workflow, so a failing `Secret scan` blocks shipping as well.
- **Flutter pinned** to `3.47.6` in all three workflows (`ci.yml:47`, `deploy-testflight.yml:45`,
  `release.yml:38`). A new stable SDK can no longer bring new lints that break `--fatal-infos`
  without warning.
- **Concurrency:** group `${{ github.workflow }}-ci-${{ github.ref }}` (`ci.yml:20-22`). Under
  `workflow_call`, `github.workflow` is the caller's name, so a deploy's `verify` run and the
  standalone CI run on the same ref do not cancel each other. `cancel-in-progress` is false on
  `refs/heads/main`, so every commit on `main` finishes verification.
- **Timeouts:** `flutter` 10 min (`ci.yml:28`), `secrets-scan` 5 min (`:71`), and 60 s per test
  (`:57`).
- **Added beyond the original scope:** ARB key parity (`ci.yml:37-41`), a coverage artifact with
  no threshold (`:59-66`), gitleaks over the full history (`:68-85`, `.gitleaks.toml`), and
  explicit `permissions: contents: read`.
- **Cloud Functions job dropped:** `functions/` was deleted, so there is nothing to verify.
- **Still External:** the first real run on GitHub, the required status check
  `Flutter analyze + test` on `main`, and the checks that a red PR cannot merge and a red `main`
  commit does not upload.

## Context

*(Historical, as of 2026-08-01.)* Three workflows existed: `deploy-testflight.yml` (push to `main`, path-filtered, builds and uploads to TestFlight), `release.yml` (tag `v*`, full App Store pipeline) and `monitor.yml` (daily cron checking App Store review status). None ran a test or a linter.

The audit found the consequences before the cause: 11 analyzer errors, two test files that failed to compile, two tests that deadlocked the runner, and a 20-minute suite. All of them reached `main` and TestFlight. They could pile up unnoticed because there was no gate.

Constraint: deploy and release need macOS and Xcode. Verification does not. Analysis, unit tests and secret scanning run on Ubuntu, which costs roughly a tenth as much per minute and starts faster.

## Goals / Non-Goals

**Goals:**
- Analysis, tests and a secret scan run automatically on every change.
- A failure blocks merging and blocks deployment and release.
- Feedback is fast enough that developers wait for it.

**Non-Goals:**
- Running `integration_test/screenshot_test.dart` in CI. It needs a simulator, which makes it slow and macOS-bound. Screenshot generation happens at release time, not per PR.
- Building the iOS app on every PR. A full macOS archive per PR is expensive and mostly redundant with the analyzer.
- Coverage thresholds. A threshold means nothing until `test-coverage-expansion` sets a baseline, and an early threshold invites tests written to hit a number. Coverage is uploaded as an artifact for visibility only.
- *(Changed:)* secret scanning was originally deferred to `secrets-hygiene`. It is now part of this gate (`secrets-scan` job).

## Decisions

**`--fatal-infos`, not plain `analyze`.** The evidence is concrete: the `ShareCard` bug was reported only as an info. The code looked up `records[5]` on a `Map<String, int>`, so the share card never showed a result. A gate that ignored infos would have let it through, just as having no gate did. The cost is that the baseline must be clean first, which `revenuecat-removal-cleanup` and `share-card-record-key-fix` delivered.

*Alternative considered:* start with errors only and tighten later. Rejected, because "tighten later" never happened for the analyzer in the whole life of this repository.

**Ubuntu, not macOS, for verification.** Neither analysis nor unit tests need Xcode.

**Reusable workflow + `needs:` for the deploy/release gate.** See Decision above.

**Separate `flutter` and `secrets-scan` jobs.** They fail for unrelated reasons, use different toolchains and need different checkouts (full history for gitleaks). *(Historical:)* a separate `functions` job was planned for the same reason and removed along with `functions/`.

**Add the workflow before making it required.** While the suite was red, a non-required workflow made the failures visible on every PR without blocking work. The prerequisites have landed. Making the check required is the remaining External step.

**Gate deployment on the checks, not just merging.** Branch protection stops a PR from merging. But `deploy-testflight.yml` fires on push to `main`, and a direct push bypasses PR protection entirely. `needs: verify` covers that path, and it also covers tag-triggered `release.yml`.

**No untrusted input in the workflows.** All steps use fixed commands. Nothing interpolates `github.event.*` into a `run:` block, and secrets and step outputs reach scripts only through `env:`.

## Risks / Trade-offs

- **A required check with a red suite blocks all work.** Mitigated by the order: add the workflow, land the three prerequisites, then make it required. Confirm the first GitHub run is green before enabling the required check.
- **`--fatal-infos` fails on a future Flutter SDK's new lints.** Resolved by pinning `3.47.6`. Upgrading is now a deliberate change that must pass CI.
- **Twenty-minute suite makes CI unusable.** Addressed by `test-suite-stabilization`. The 10-minute job timeout and 60-second per-test timeout keep a regression from going unnoticed.
- **PRs from forks cannot read secrets.** Neither verification job needs secrets, so fork PRs can be fully verified.
- **The full-history secret scan can flag commits that are already public.** Gitleaks scans every commit, including content deleted since. The allowlist (`.gitleaks.toml:7-13`) covers only the current Firebase config paths. Any historical copy elsewhere (for example the deleted `brainy-app/docs/setup/firebase/Brainy App Google Service Info.plist`, added in the initial commit) will fail `Secret scan`, which blocks deploy and release through `needs: verify`. Check this on the first run and extend the allowlist (by path or commit) or set a baseline if needed.
- **"Never cancelled on `main`" has a limit.** With `cancel-in-progress: false`, GitHub keeps one running and one *pending* run per group. A third push replaces the pending one, so with three or more quick pushes to `main` an intermediate commit's run (and, for deploy, its `verify` and therefore its upload) is cancelled. This is accepted, because the newest commit is still verified and deployed.
- **Double runs on `main`.** A push to `main` runs CI standalone and again as the deploy's `verify` job. This is accepted, because the cost is small (Ubuntu) and the deploy is gated on its own SHA.

## Migration Plan

1. Add `ci.yml`. (done)
2. Land `revenuecat-removal-cleanup`, which removes the analyzer errors. (done)
3. Land `share-card-record-key-fix`, which removes the last analyzer info. (done)
4. Land `test-suite-stabilization`, which makes the suite green and fast. (done)
5. Make `deploy-testflight.yml` and `release.yml` depend on the gate (`verify` + `needs`). (done)
6. Push and confirm a green run. (External)
7. Enable the required status check `Flutter analyze + test` on `main`. (External)

**Rollback:** remove the `verify` job and `needs:` from deploy/release, delete `ci.yml`, and remove the required check. There is no production impact.

## Open Questions (resolved)

- *`workflow_run` or inlined `needs:`?* Neither as originally framed. The project uses a reusable workflow (`workflow_call`) with `needs: verify`, which avoids both the `workflow_run` problems and duplicated YAML. See Decision.
- *Pin the Flutter version?* Yes, `3.47.6` in every workflow.
- *Required check for the `functions` job before it is deleted?* Moot. The package and the job are both gone.
