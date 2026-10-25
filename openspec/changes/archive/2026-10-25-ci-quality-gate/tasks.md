Status legend: `[x]` done (evidence cited), `[~]` dropped / not applicable (reason given),
`[ ] External:` needs GitHub (a real run or repository settings) and cannot be done in the repo.
Verified against the files on branch `chore/finish-audit-changes` (2026-10-25). CI has not yet run
on GitHub: the branch is not pushed.

## 1. Add the workflow

- [x] 1.1 Create `.github/workflows/ci.yml` triggered on `pull_request` and `push` to `main`
  — `ci.yml:3-9`; it also has `workflow_call` (`:9`) so deploy and release can reuse it
- [x] 1.2 Add the `flutter` job on `ubuntu-latest`: checkout, setup Flutter (stable, cached), `flutter pub get`, `flutter analyze --fatal-infos`, `flutter test`
  — `ci.yml:25-57`; Flutter is pinned to `3.47.6` with cache rather than tracking `stable` (`:43-48`, see 4.3); the job also checks ARB key parity (`:37-41`) and runs tests with `--timeout 60s --coverage` (`:57`)
- [~] 1.3 Add the `functions` job on `ubuntu-latest`: setup Node 20 with npm cache, `npm ci`, `npm run build`, `npm test`
  — dropped: `functions/` no longer exists (removed by `remove-monetization-go-free`), so `ci.yml` has no `functions` job
- [x] 1.4 Add a `concurrency` group keyed on the ref with `cancel-in-progress: true`
  — done in a changed form: `ci.yml:20-22`, group `${{ github.workflow }}-ci-${{ github.ref }}`, `cancel-in-progress` only when the ref is not `refs/heads/main`. Runs on `main` are never cancelled, and a gate run from deploy/release never cancels the standalone CI run (comment `:17-19`)
- [x] 1.5 Confirm no step interpolates untrusted `github.event.*` input into a `run:` block
  — no `github.event` anywhere in `.github/workflows/`; the only `${{ }}` in `run:`-adjacent code goes through `env:` (`ci.yml:80-81`, `deploy-testflight.yml:65-79`, `release.yml:58-72`, `monitor.yml:79-82`)
- [x] 1.6 External: push the branch / open a scratch pull request and confirm both `Flutter analyze + test` and `Secret scan` trigger, pass, and finish within the 10-minute budget. This first green run is the evidence still missing for 2.1-2.4. Expect a red `Secret scan` first time — see the risk in design.md (historical Firebase key outside the allowlist) — done: CI run 40215196878 on PR #21: both jobs green (Flutter 2m30s, Secret scan 7s), after making the repo public (Actions billing had blocked every job)
- [x] 1.7 Add explicit least-privilege permissions
  — `permissions: contents: read` in `ci.yml:11-12`, `deploy-testflight.yml:15-16`, `release.yml:8-9`
- [x] 1.8 Add a gitleaks secret scan
  — `secrets-scan` job, `ci.yml:68-85`: full history (`fetch-depth: 0`, `:76-77`), gitleaks 8.30.1 (`:81`), config `.gitleaks.toml` (`:85`; allowlist for public Firebase keys at `.gitleaks.toml:7-13`)
- [x] 1.9 Upload a coverage report without a threshold
  — `ci.yml:59-66`, artifact `coverage-lcov`, `if-no-files-found: ignore`; no threshold anywhere

## 2. Make the gate passable

- [x] 2.1 Land `revenuecat-removal-cleanup` and confirm the analyzer step passes
  — landed (see that change's tasks.md and `remove-monetization-go-free` 7.1). Confirmation on GitHub is tracked in 1.6
- [x] 2.2 Land `share-card-record-key-fix` and confirm `--fatal-infos` passes
  — landed (that change's 1.3 / 4.1); `--fatal-infos` is enforced at `ci.yml:54`. Confirmation on GitHub is tracked in 1.6
- [x] 2.3 Land `test-suite-stabilization` and confirm the test step passes
  — deadlock fix landed (that change's 3.x); `--timeout 60s` (`ci.yml:57`) stops a single hung test from using up the job. Confirmation on GitHub is tracked in 1.6
- [x] 2.4 Confirm the whole workflow completes in under ten minutes
  — enforced as a hard ceiling: `timeout-minutes: 10` on `flutter` (`ci.yml:28`) and `5` on `secrets-scan` (`:71`). The real run time is measured in 1.6

## 3. Enforce it

- [x] 3.1 External: in branch protection for `main`, add the required status check named exactly `Flutter analyze + test` (job name, `ci.yml:26`), and optionally `Secret scan` (`ci.yml:69`) — done: branch protection on main requires `Flutter analyze + test` and `Secret scan` (set 2026-10-25)
- [ ] 3.2 External: verify a pull request with a deliberately failing test cannot be merged
- [x] 3.3 Decide how `deploy-testflight.yml` depends on the gate (`workflow_run` versus an inlined `needs:` job)
  — decided: reusable workflow + `needs:`. `ci.yml` is called as job `verify` and the build job `needs: verify`. Reasons in design.md, Decision
- [x] 3.4 Implement that dependency
  — `deploy-testflight.yml:23-27` (`verify: uses: ./.github/workflows/ci.yml`, `deploy: needs: verify`); same in `release.yml:16-20`
- [ ] 3.5 External: verify a red commit on `main` does not produce a TestFlight upload (the `deploy` job shows as skipped when `verify` fails)

## 4. Keep it honest as the project changes

- [x] 4.1 Remove the `functions` job when `remove-monetization-go-free` deletes `functions/`
  — `functions/` is gone and `ci.yml` has no `functions` job
- [x] 4.2 Review the `deploy-testflight.yml` path filter after that deletion
  — `deploy-testflight.yml:7-13` lists only `brainy-app/` app paths (lib, pubspec, ios, l10n, assets); nothing references `functions/`
- [x] 4.3 Decide whether to pin the Flutter version instead of tracking `stable`
  — pinned to `3.47.6` everywhere: `ci.yml:47`, `deploy-testflight.yml:45`, `release.yml:38`
- [x] 4.4 Record in `CLAUDE.md` that analysis and tests are enforced in CI, so contributors expect it
  — `CLAUDE.md:48-54` ("CI uses --fatal-infos"; CI runs ARB parity, analyze, test, gitleaks; deploy/release use a required `verify` job)
- [~] 4.5 Add a required check for the `functions` job before it is deleted (design Open Question 3)
  — moot: the package and the job are both gone
