## Outcome (2026-10-25)

Repository work is complete (commits `f0e1ec8`, `9180bab`, `faf276b` on `chore/finish-audit-changes`):

- `.gitignore` covers `secrets/`, `.secrets/` and every signing extension; verified with `git check-ignore -v` and `git add -A --dry-run`. No signing file is tracked.
- `brainy-app/docs/setup/revenue_cat/` is deleted; no code, Fastfile lane or workflow references `REVENUECAT_API_KEY` any more.
- CI runs gitleaks over full history (`secrets-scan` job); `.gitleaks.toml` allowlists only the public Firebase iOS config.
- `CLAUDE.md` requires verifying ignore patterns with `git check-ignore -v <real path>`.

Decisions:
- **History is not rewritten** (task 3.1). The leaked keys remain readable in history; revocation is the remediation.
- **No replacement key.** The app is fully free; RevenueCat is not needed.

Still pending, account owner only (External): revoke the RevenueCat keys, delete the `REVENUECAT_API_KEY` GitHub secret, confirm the old keys no longer authenticate; optionally restrict the Firebase iOS API key in Google Cloud.

---

*The sections below are the original 2026-08-01 proposal, kept for history. Where they conflict with the Outcome above, the Outcome wins.*

## Why

A production RevenueCat API key was committed to git (`brainy-app/docs/setup/revenue_cat/credentials.md`) and is present in repository history. (A later content search found a second RevenueCat SDK key in the history of `brainy-app/lib/constants/app_constants.dart`.) Separately, the `secrets/` directory holding the iOS distribution certificate (`Certificates.p12`), two App Store Connect private keys (`AuthKey_Q2Q32CN7T9.p8`, `SubscriptionKey_WH6Q4W9JG2.p8`), a provisioning profile and a distribution certificate was untracked but **not** ignored — the ignore rule read `.secrets/` (leading dot) while the real folder is `secrets/`. A single `git add .` would have published every signing credential the project owns.

## What Changes

- Ignore rules cover the real secret-bearing paths (`secrets/`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.cer`, `*.keystore`, `*.jks`) instead of a non-existent `.secrets/` folder.
- The `brainy-app/docs/setup/revenue_cat/` folder — a leftover of the abandoned RevenueCat integration — is deleted, removing the credentials file from the working tree.
- The leaked RevenueCat key is revoked at the provider, because deletion from the working tree does not undo its exposure in history. ~~and reissued~~ — no replacement: RevenueCat is not used.
- ~~Repository history is purged of the credentials file so that clones and forks stop carrying the key.~~ **Superseded by decision 3.1:** history is not rewritten; the revoked key may remain in history.
- A verification step proves the ignore rules actually match the real files, rather than assuming a pattern is correct.
- *Added during implementation:* a CI secret scan (gitleaks, full history) so the class of defect is caught automatically.

~~**BREAKING** — purging history rewrites commit SHAs on `main`. Every existing clone must re-clone or hard-reset.~~ Not applicable: no history rewrite (decision 3.1), so nothing is breaking.

## Capabilities

### New Capabilities
- `secret-management`: how credentials and signing material are kept out of version control, verified, scanned for in CI, and revoked after exposure.

### Modified Capabilities
<!-- None: openspec/specs/ is empty; this is the first capability. -->

## Impact

- `.gitignore` — ignore rules for signing material and fastlane build artifacts.
- `brainy-app/docs/setup/revenue_cat/` — deleted (`credentials.md`, `initialize.dart`, `prompt.md`). `initialize.dart` was also one of the sources of the `flutter analyze` failures addressed by the `revenuecat-removal-cleanup` change.
- `brainy-app/ios/fastlane/Fastfile`, `.github/workflows/deploy-testflight.yml`, `release.yml` — `REVENUECAT_API_KEY` plumbing removed.
- `.github/workflows/ci.yml`, `.gitleaks.toml` — secret-scan job and allowlist.
- `CLAUDE.md` — `git check-ignore` rule in Architecture Rules.
- ~~Git history on `main` — rewritten~~ — unchanged (decision 3.1).
- RevenueCat account — keys revoked (External, pending); no reissue. *Historical:* at proposal time `SubscriptionService` was a stub and payments were planned via YooKassa; both are gone — the app is fully free.
- `secrets/` contents remain on disk for local fastlane runs; only their exposure changes.
