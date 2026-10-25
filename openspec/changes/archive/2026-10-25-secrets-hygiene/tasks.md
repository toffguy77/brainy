> Status 2026-10-25: all repository work is done (commits `f0e1ec8`, `9180bab`, `faf276b`).
> Only account-owner actions remain, marked **External**. History is not rewritten (decision 3.1).

## 1. Close the exposure in the working tree

- [x] 1.1 Replace the non-matching `.secrets/` rule in `.gitignore` with `secrets/`, `.secrets/`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.cer`, `*.keystore`, `*.jks` — `.gitignore:24-32`
- [x] 1.2 Add ignore rules for fastlane build artifacts (`brainy-app/ios/fastlane/README.md`, `brainy-app/ios/fastlane/report.xml`) — `.gitignore:35-36`, confirmed by `git check-ignore -v`
- [x] 1.3 Delete `brainy-app/docs/setup/revenue_cat/` (`credentials.md`, `initialize.dart`, `prompt.md`) — deleted in `f0e1ec8`; directory absent, `git ls-files` empty
- [x] 1.4 Verify with `git check-ignore -v` that `secrets/Certificates.p12` and `secrets/AuthKey_Q2Q32CN7T9.p8` are reported as ignored — both match `.gitignore:25:secrets/`
- [x] 1.5 Verify `git status --porcelain` no longer lists `secrets/` or the fastlane artifacts — re-checked 2026-10-25
- [x] 1.6 Verify `git add -A --dry-run` output contains no path under `secrets/` and no signing-extension file — checked by the maintainer before `f0e1ec8`, re-checked 2026-10-25 (no match); `git ls-files` also has no `secrets/`, `.p12`, `.p8`, `.mobileprovision`, `.cer`, `.jks`, `.keystore`
- [x] 1.7 Commit the ignore rules and deletions — `f0e1ec8` (`.gitignore` +17, `revenue_cat/` removed)

## 2. Revoke the exposed credential

- [x] 2.1 Grep the tree for remaining uses of `revenueCatApiKey` / `REVENUECAT_API_KEY` to confirm nothing reads the key at runtime — no hits in `brainy-app/`, `.github/`, `Fastfile` (only historical audit docs mention them)
- [ ] 2.2 External: revoke the leaked RevenueCat keys in the RevenueCat dashboard. Scope: the key from `credentials.md` **and** the iOS SDK key that sat in `brainy-app/lib/constants/app_constants.dart` (added `5da142d`, commented copy in `3b9684a`, removed `f0e1ec8`) — simplest is to revoke all keys or delete the RevenueCat project
- [~] 2.3 Issue a replacement key only if a consumer exists — N/A: owner decision 2026-10-25, the app is fully free and RevenueCat is not needed, so no replacement key is ever issued (`SubscriptionService` was deleted in `f0e1ec8`)
- [x] 2.4 Remove the `REVENUECAT_API_KEY` `--dart-define` from `brainy-app/ios/fastlane/Fastfile` and the workflows — done in `9180bab` (Fastfile, `deploy-testflight.yml`, `release.yml`); GitHub secret deletion split out to 2.6
- [ ] 2.5 External: confirm the old keys no longer authenticate (a RevenueCat API call with the old key is rejected)
- [ ] 2.6 External: delete the `REVENUECAT_API_KEY` repository secret in GitHub (Settings → Secrets and variables → Actions)

## 3. Purge history

- [x] 3.1 Decided 2026-08-01: skip the rewrite, rely on revocation — rationale in `design.md`
- [~] 3.2 Merge or close the open dependabot PR (`fast-xml-parser 5.5.6 → 5.5.7`) so no PR needs rebasing after the rewrite — dropped by the decision in 3.1
- [~] 3.3 Take a safety mirror: `git clone --mirror` to an off-repo location — dropped by the decision in 3.1
- [~] 3.4 Announce the rewrite to collaborators — dropped by the decision in 3.1
- [~] 3.5 Run `git filter-repo --path brainy-app/docs/setup/revenue_cat --invert-paths` — dropped by the decision in 3.1
- [~] 3.6 Search history by content (`git log --all -S '<key fragment>'`) to catch copies under other paths or older names — dropped as a purge step by 3.1; the content search was still run (2026-10-25) to scope revocation and found the second copy in `app_constants.dart` history (see 2.2)
- [~] 3.7 Force-push `main` — dropped by the decision in 3.1
- [~] 3.8 Re-clone and verify `git log --all --oneline -- brainy-app/docs/setup/revenue_cat/credentials.md` is empty — dropped by the decision in 3.1; the file intentionally remains in history (`e1ad601`)

## 4. Prevent recurrence

- [x] 4.1 Document in `CLAUDE.md` that ignore patterns must be verified with `git check-ignore` against a real path before being accepted — `CLAUDE.md:106` (Architecture Rules), commit `faf276b`
- [x] 4.2 Add a secret-scanning step (`gitleaks`) to the CI gate — `secrets-scan` job in `.github/workflows/ci.yml` (gitleaks 8.30.1, `fetch-depth: 0`, full history, `--redact`), config `.gitleaks.toml` allowlists only the public Firebase iOS config; local run over history: no leaks. Note: gitleaks does not detect the historic RevenueCat keys, so it is no substitute for 2.2
- [ ] 4.3 External (optional): restrict the Firebase iOS API key in Google Cloud Console (iOS bundle ID restriction + API restriction)
