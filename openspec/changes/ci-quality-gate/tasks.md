## 1. Add the workflow

- [x] 1.1 Create `.github/workflows/ci.yml` triggered on `pull_request` and `push` to `main`
- [x] 1.2 Add the `flutter` job on `ubuntu-latest`: checkout, setup Flutter (stable, cached), `flutter pub get`, `flutter analyze --fatal-infos`, `flutter test`
- [x] 1.3 Add the `functions` job on `ubuntu-latest`: setup Node 20 with npm cache, `npm ci`, `npm run build`, `npm test`
- [x] 1.4 Add a `concurrency` group keyed on the ref with `cancel-in-progress: true`
- [x] 1.5 Confirm no step interpolates untrusted `github.event.*` input into a `run:` block
- [ ] 1.6 Open a scratch pull request and confirm both jobs are triggered

## 2. Make the gate passable

- [x] 2.1 Land `revenuecat-removal-cleanup` and confirm the analyzer step passes
- [x] 2.2 Land `share-card-record-key-fix` and confirm `--fatal-infos` passes
- [x] 2.3 Land `test-suite-stabilization` and confirm the test step passes
- [x] 2.4 Confirm the whole workflow completes in under ten minutes

## 3. Enforce it

- [ ] 3.1 Enable the `flutter` job as a required status check on `main` in branch protection
- [ ] 3.2 Verify a pull request with a deliberately failing test cannot be merged
- [ ] 3.3 Decide how `deploy-testflight.yml` depends on the gate (`workflow_run` versus an inlined `needs:` job) — see design Open Questions
- [ ] 3.4 Implement that dependency
- [ ] 3.5 Verify a red commit on `main` does not produce a TestFlight upload

## 4. Keep it honest as the project changes

- [x] 4.1 Remove the `functions` job when `remove-monetization-go-free` deletes `functions/`
- [x] 4.2 Review the `deploy-testflight.yml` path filter after that deletion
- [ ] 4.3 Decide whether to pin the Flutter version instead of tracking `stable`
- [ ] 4.4 Record in `CLAUDE.md` that analysis and tests are enforced in CI, so contributors expect it
