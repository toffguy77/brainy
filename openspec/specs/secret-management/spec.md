# secret-management Specification

## Purpose
TBD - created by archiving change secrets-hygiene. Update Purpose after archive.

## Requirements

### Requirement: Signing material is excluded from version control

The repository SHALL ignore every path that holds signing or authentication material, matched by both directory name and file extension so that a credential is excluded regardless of where it is placed.

Covered patterns: `secrets/`, `.secrets/`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.cer`, `*.keystore`, `*.jks`.

#### Scenario: Signing files in the secrets directory are ignored

- **WHEN** `git check-ignore secrets/Certificates.p12` and `git check-ignore secrets/AuthKey_Q2Q32CN7T9.p8` are run
- **THEN** each exits `0`, reporting the file as ignored

#### Scenario: Signing files outside the secrets directory are ignored

- **WHEN** a `.p12`, `.p8`, `.mobileprovision`, `.cer`, `.keystore` or `.jks` file is created anywhere in the working tree
- **THEN** `git status --porcelain` does not list it as untracked

#### Scenario: Staging everything does not capture credentials

- **WHEN** `git add -A --dry-run` is run from the repository root
- **THEN** its output contains no path under `secrets/` and no file with a signing extension

#### Scenario: No signing file is tracked

- **WHEN** `git ls-files` is filtered for `secrets/` and the signing extensions
- **THEN** the result is empty

### Requirement: Ignore rules are verified against real paths, not assumed

Ignore rules SHALL be validated by executing `git check-ignore` against the actual files on disk. A pattern is not considered correct because it looks plausible. The rule SHALL be recorded in the project rules (`CLAUDE.md`, Architecture Rules) so that every contributor and agent applies it.

This requirement exists because the defect being fixed was exactly this: the rule `.secrets/` was present and appeared to cover the `secrets/` folder, but matched nothing.

#### Scenario: A pattern that matches nothing is rejected

- **WHEN** an ignore pattern is added or changed
- **THEN** `git check-ignore -v <real-path>` is run for at least one real file the pattern is meant to cover, and the pattern is only accepted if the command reports a match

### Requirement: No credential material is tracked in the working tree

The repository SHALL NOT track files whose purpose is to carry credentials, API keys, or tokens, and SHALL NOT pass unused credentials into builds.

#### Scenario: RevenueCat credentials file is gone

- **WHEN** `git ls-files brainy-app/docs/setup/revenue_cat` is run
- **THEN** the output is empty and the directory does not exist on disk

#### Scenario: No build path reads the RevenueCat key

- **WHEN** `brainy-app/`, `brainy-app/ios/fastlane/Fastfile` and `.github/workflows/` are searched for `REVENUECAT_API_KEY` and `revenueCatApiKey`
- **THEN** there are no matches

### Requirement: CI scans the full history for secrets

CI SHALL run a secret scanner (gitleaks) over the complete git history on every CI run, and a finding SHALL fail the job. The scanner configuration SHALL allowlist only public Firebase client configuration (the Firebase iOS API key in `brainy-app/lib/firebase_options.dart` and `brainy-app/ios/Runner/GoogleService-Info.plist`); no other path or rule SHALL be allowlisted. Findings SHALL be redacted in logs.

#### Scenario: Scan covers full history

- **WHEN** the `secrets-scan` job in `.github/workflows/ci.yml` runs
- **THEN** the repository is checked out with `fetch-depth: 0` and `gitleaks git --redact --config .gitleaks.toml .` scans every commit

#### Scenario: A committed secret fails CI

- **WHEN** a commit introduces a value matching a gitleaks rule outside the Firebase allowlist
- **THEN** the `secrets-scan` job fails and the secret value is not printed in the log

#### Scenario: Public Firebase config does not fail CI

- **WHEN** the scan encounters the Firebase iOS API key in an allowlisted path
- **THEN** it is not reported as a leak

#### Scenario: Scanner is not treated as proof of revocation

- **WHEN** the scan passes
- **THEN** that is not taken as evidence that historic credentials are safe, because the scanner does not detect every provider's key format (it does not flag the historic RevenueCat keys)

### Requirement: Exposed credentials are revoked, not just deleted

When a credential has been committed to version control, the system owner SHALL revoke it at the issuing provider. Removing the file SHALL NOT be treated as remediation on its own, because the value remains readable in history, in existing clones, and in any fork. A replacement SHALL be issued only if a consumer exists.

#### Scenario: Leaked RevenueCat keys are revoked

- **WHEN** the RevenueCat keys found in history (`brainy-app/docs/setup/revenue_cat/credentials.md` and `brainy-app/lib/constants/app_constants.dart`) are remediated
- **THEN** each old key is revoked in the RevenueCat dashboard and no longer authenticates
- **AND** the unused `REVENUECAT_API_KEY` GitHub secret is deleted
- **AND** no replacement key is issued, because the app does not use RevenueCat

### Requirement: Revoked credentials may remain in history

Repository history SHALL NOT be rewritten to remove a credential once it has been revoked. A revoked key MAY remain readable in history; revocation is the remediation. The secret scanner's allowlist SHALL NOT be used to hide such residue — it is reserved for public Firebase configuration.

#### Scenario: History is left intact

- **WHEN** a leaked credential has been revoked
- **THEN** `main` is not force-pushed and existing clones remain valid

#### Scenario: Residue is not allowlisted

- **WHEN** `.gitleaks.toml` is inspected
- **THEN** its allowlist contains only the Firebase client configuration paths

### Requirement: Build artifacts do not pollute repository status

Generated fastlane output SHALL be ignored so that a dirty working tree signals real, reviewable changes.

#### Scenario: Fastlane artifacts are ignored

- **WHEN** fastlane regenerates `brainy-app/ios/fastlane/README.md` and `brainy-app/ios/fastlane/report.xml`
- **THEN** `git status --porcelain` does not list them
