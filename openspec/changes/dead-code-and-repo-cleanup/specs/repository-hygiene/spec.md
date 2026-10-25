## ADDED Requirements

### Requirement: No unreferenced source files remain in the application

Every Dart file under `brainy-app/lib/` SHALL be reachable from `lib/main.dart` through `import`, `export` or `part` directives. A file that is not reachable SHALL be deleted or wired up. It MUST NOT be left in place.

#### Scenario: The dead parent screen is gone

- **WHEN** `lib/`, `test/` and `integration_test/` are searched for `ParentScreen`
- **THEN** no definition or reference remains

#### Scenario: Scaffold orphans are gone

- **WHEN** the tree is searched for `firebase_service.dart`, `brainy_button.dart`, `brainy_card.dart` and `app_text_styles.dart`
- **THEN** none of these files exist

#### Scenario: The import graph covers the whole tree

- **WHEN** the import graph is walked from `lib/main.dart`
- **THEN** every Dart file under `lib/` is reached

### Requirement: The unreferenced-file standard is enforced at review

The `/review` checklist (`.claude/commands/review.md`) SHALL include a check that every new Dart file in `lib/` is imported or routed. It SHALL also include a check that every identifier a touched plan names exists in code, and a check that every new setting or control has a consumer.

#### Scenario: A reviewer runs /review

- **WHEN** the `/review` checklist is read
- **THEN** it contains the unreferenced-file, plan-identifier and decorative-control items

### Requirement: Localization keys are all in use

Every key in `l10n/app_en.arb` SHALL also exist in `l10n/app_ru.arb`, and the reverse. Every key SHALL be read from `lib/` or `test/`.

#### Scenario: No orphan ARB keys

- **WHEN** each non-metadata key in `app_en.arb` is searched for in `lib/` (excluding `lib/l10n/`) and `test/`
- **THEN** every key has at least one usage

#### Scenario: Locales match

- **WHEN** the key sets of `app_en.arb` and `app_ru.arb` are compared
- **THEN** they are identical

### Requirement: All user-facing text is localized

No widget SHALL contain a hardcoded user-facing string. Every displayed string SHALL come from the ARB files.

#### Scenario: No hardcoded Russian or English strings

- **WHEN** `lib/` (excluding `lib/l10n/`) is searched for `Text('...')` and `Text("...")` with literal content
- **THEN** the only matches are non-linguistic symbols such as emoji

#### Scenario: The last hardcoded label is gone

- **WHEN** `lib/` is searched for `Родитель` outside `lib/l10n/`
- **THEN** no match remains

### Requirement: Declared asset directories exist and are populated

`pubspec.yaml` MUST NOT declare an asset directory that is missing or empty. Asset declarations SHALL be added together with the assets they declare.

#### Scenario: Every declared directory has assets

- **WHEN** each directory under `flutter.assets` in `pubspec.yaml` is inspected
- **THEN** every one exists and contains at least one asset

#### Scenario: The animations declaration is gone

- **WHEN** `pubspec.yaml` and `brainy-app/assets/` are inspected
- **THEN** `assets/animations/` is neither declared nor present

### Requirement: The repository root holds no generated or machine-local files

Logs and OS metadata MUST NOT be present in the repository, and `.gitignore` SHALL cover them.

#### Scenario: No debug log or OS metadata

- **WHEN** the repository root is listed
- **THEN** neither `firebase-debug.log` nor `.DS_Store` is present

#### Scenario: Recreated files stay ignored

- **WHEN** `git check-ignore` is run on `firebase-debug.log` and `.DS_Store`
- **THEN** both are matched by `.gitignore`

### Requirement: Working tree status is a meaningful signal

`git status --porcelain` on a clean checkout SHALL produce no output, so that every entry it shows is a real, reviewable change.

#### Scenario: A clean checkout reports nothing

- **WHEN** `git status --porcelain` is run on a checkout with no edits
- **THEN** it produces no output

#### Scenario: Fastlane artifacts do not appear

- **WHEN** a fastlane run regenerates `brainy-app/ios/fastlane/README.md` and `report.xml`
- **THEN** `.gitignore` matches both, and neither appears as untracked

#### Scenario: Review screenshots are ignored

- **WHEN** `git check-ignore` is run on `brainy-app/screenshots/review_*.png`
- **THEN** every file matches the `.gitignore` rule that documents them as local-only App Review evidence of the removed paywall
