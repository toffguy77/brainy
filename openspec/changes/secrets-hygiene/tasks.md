## 1. Close the exposure in the working tree

- [x] 1.1 Replace the non-matching `.secrets/` rule in `.gitignore` with `secrets/`, `.secrets/`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.cer`, `*.keystore`, `*.jks`
- [x] 1.2 Add ignore rules for fastlane build artifacts (`brainy-app/ios/fastlane/README.md`, `brainy-app/ios/fastlane/report.xml`)
- [x] 1.3 Delete `brainy-app/docs/setup/revenue_cat/` (`credentials.md`, `initialize.dart`, `prompt.md`)
- [x] 1.4 Verify with `git check-ignore -v` that `secrets/Certificates.p12` and `secrets/AuthKey_Q2Q32CN7T9.p8` are reported as ignored
- [x] 1.5 Verify `git status --porcelain` no longer lists `secrets/` or the fastlane artifacts
- [ ] 1.6 Verify `git add -A --dry-run` output contains no path under `secrets/` and no signing-extension file
- [ ] 1.7 Commit the ignore rules and deletions

## 2. Revoke the exposed credential

- [ ] 2.1 Grep the tree for remaining uses of `revenueCatApiKey` / `REVENUECAT_API_KEY` to confirm nothing reads the key at runtime
- [ ] 2.2 Revoke the leaked key in the RevenueCat dashboard
- [ ] 2.3 Issue a replacement key only if a consumer exists; otherwise record that no replacement is needed while `SubscriptionService` is a stub
- [ ] 2.4 Delete the now-unused `REVENUECAT_API_KEY` GitHub secret and its `--dart-define` in `brainy-app/ios/fastlane/Fastfile`
- [ ] 2.5 Confirm the old key no longer authenticates

## 3. Purge history

- [x] 3.1 Decided 2026-08-01: skip the rewrite, rely on revocation — rationale in `design.md`
- [~] 3.2 Merge or close the open dependabot PR (`fast-xml-parser 5.5.6 → 5.5.7`) so no PR needs rebasing after the rewrite — dropped by the decision in 3.1
- [~] 3.3 Take a safety mirror: `git clone --mirror` to an off-repo location — dropped by the decision in 3.1
- [~] 3.4 Announce the rewrite to collaborators — dropped by the decision in 3.1
- [~] 3.5 Run `git filter-repo --path brainy-app/docs/setup/revenue_cat --invert-paths` — dropped by the decision in 3.1
- [~] 3.6 Search history by content (`git log --all -S '<key fragment>'`) to catch copies under other paths or older names — dropped by the decision in 3.1
- [~] 3.7 Force-push `main` — dropped by the decision in 3.1
- [~] 3.8 Re-clone and verify `git log --all --oneline -- brainy-app/docs/setup/revenue_cat/credentials.md` is empty — dropped by the decision in 3.1

## 4. Prevent recurrence

- [ ] 4.1 Document in `CLAUDE.md` that ignore patterns must be verified with `git check-ignore` against a real path before being accepted
- [ ] 4.2 Evaluate adding a secret-scanning step (`gitleaks`) to the CI gate introduced by the `ci-quality-gate` change
