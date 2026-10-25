## Why

A production RevenueCat API key was committed to git (`brainy-app/docs/setup/revenue_cat/credentials.md`) and is present in repository history. Separately, the `secrets/` directory holding the iOS distribution certificate (`Certificates.p12`), two App Store Connect private keys (`AuthKey_Q2Q32CN7T9.p8`, `SubscriptionKey_WH6Q4W9JG2.p8`), a provisioning profile and a distribution certificate was untracked but **not** ignored — the ignore rule read `.secrets/` (leading dot) while the real folder is `secrets/`. A single `git add .` would have published every signing credential the project owns.

## What Changes

- Ignore rules cover the real secret-bearing paths (`secrets/`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.cer`, `*.keystore`, `*.jks`) instead of a non-existent `.secrets/` folder.
- The `brainy-app/docs/setup/revenue_cat/` folder — a leftover of the abandoned RevenueCat integration — is deleted, removing the credentials file from the working tree.
- The leaked RevenueCat key is revoked and reissued at the provider, because deletion from the working tree does not undo its exposure in history.
- Repository history is purged of the credentials file so that clones and forks stop carrying the key.
- A verification step proves the ignore rules actually match the real files, rather than assuming a pattern is correct.

**BREAKING** — purging history rewrites commit SHAs on `main`. Every existing clone must re-clone or hard-reset.

## Capabilities

### New Capabilities
- `secret-management`: how credentials and signing material are kept out of version control, verified, and rotated after exposure.

### Modified Capabilities
<!-- None: openspec/specs/ is empty; this is the first capability. -->

## Impact

- `.gitignore` — ignore rules for signing material and fastlane build artifacts.
- `brainy-app/docs/setup/revenue_cat/` — deleted (`credentials.md`, `initialize.dart`, `prompt.md`). `initialize.dart` was also one of the sources of the `flutter analyze` failures addressed by the `revenuecat-removal-cleanup` change.
- Git history on `main` — rewritten; all collaborators and any CI caches keyed on SHAs are affected.
- RevenueCat account — key revoked and reissued. Note the app does not currently call RevenueCat (`SubscriptionService` is a stub), so revocation carries no runtime risk today.
- `secrets/` contents remain on disk for local fastlane runs; only their exposure changes.
