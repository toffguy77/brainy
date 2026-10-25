## ADDED Requirements

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

### Requirement: Ignore rules are verified against real paths, not assumed

Ignore rules SHALL be validated by executing `git check-ignore` against the actual files on disk. A pattern is not considered correct because it looks plausible.

This requirement exists because the defect being fixed was exactly this: the rule `.secrets/` was present and appeared to cover the `secrets/` folder, but matched nothing.

#### Scenario: A pattern that matches nothing is rejected

- **WHEN** an ignore pattern is added or changed
- **THEN** `git check-ignore -v <real-path>` is run for at least one real file the pattern is meant to cover, and the pattern is only accepted if the command reports a match

### Requirement: No credential material is tracked in the working tree

The repository SHALL NOT track files whose purpose is to carry credentials, API keys, or tokens.

#### Scenario: RevenueCat credentials file is gone

- **WHEN** `git ls-files brainy-app/docs/setup/revenue_cat` is run
- **THEN** the output is empty and the directory does not exist on disk

#### Scenario: Repository scan finds no tracked secrets

- **WHEN** a secret-scanning pass is run over the tracked file list
- **THEN** it reports no API keys, private keys, or certificates

### Requirement: Exposed credentials are revoked, not just deleted

When a credential has been committed to version control, the system owner SHALL revoke and reissue it at the issuing provider. Removing the file SHALL NOT be treated as remediation on its own, because the value remains readable in history, in existing clones, and in any fork.

#### Scenario: Leaked RevenueCat key is revoked

- **WHEN** the RevenueCat key found in `brainy-app/docs/setup/revenue_cat/credentials.md` is remediated
- **THEN** the old key is revoked in the RevenueCat dashboard and no longer authenticates
- **AND** any replacement key is delivered through CI secrets, never through a tracked file

### Requirement: Exposed credentials are purged from history

Repository history SHALL NOT contain the leaked credentials file after remediation.

#### Scenario: History no longer contains the credentials file

- **WHEN** `git log --all --oneline -- brainy-app/docs/setup/revenue_cat/credentials.md` is run after the purge
- **THEN** the output is empty

#### Scenario: Collaborators are told to re-clone

- **WHEN** history is rewritten on `main`
- **THEN** every collaborator is notified that existing clones are invalid and must be re-cloned or hard-reset

### Requirement: Build artifacts do not pollute repository status

Generated fastlane output SHALL be ignored so that a dirty working tree signals real, reviewable changes.

#### Scenario: Fastlane artifacts are ignored

- **WHEN** fastlane regenerates `brainy-app/ios/fastlane/README.md` and `brainy-app/ios/fastlane/report.xml`
- **THEN** `git status --porcelain` does not list them
