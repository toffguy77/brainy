## ADDED Requirements

### Requirement: No unreferenced source files remain in the application

Every Dart file under `lib/` SHALL be reachable from the application — imported by another file, or registered as a route. A file that is neither SHALL be deleted or wired up.

#### Scenario: The dead parent screen is gone

- **WHEN** the codebase is searched for `ParentScreen`
- **THEN** no definition or reference remains

#### Scenario: Unreferenced files are identified

- **WHEN** the tree is audited for unreferenced Dart files
- **THEN** each one found is either wired into the app or removed, with no file left in an unresolved state

### Requirement: All user-facing text is localized

No widget SHALL contain a hardcoded user-facing string. Every displayed string SHALL come from the ARB files.

#### Scenario: No hardcoded Russian or English strings

- **WHEN** `lib/` is searched for `Text('...')` and `Text("...")` with literal content
- **THEN** the only matches are non-linguistic symbols such as emoji

#### Scenario: The last hardcoded label is gone

- **WHEN** the codebase is searched for `Text('Родитель')`
- **THEN** no match remains

### Requirement: Declared asset directories are populated

`pubspec.yaml` SHALL NOT declare an asset directory that is empty.

#### Scenario: No empty asset declaration

- **WHEN** each asset directory declared in `pubspec.yaml` is inspected
- **THEN** every one contains at least one asset

#### Scenario: The animations directory is resolved

- **WHEN** `assets/animations/` is inspected
- **THEN** it either contains assets or is no longer declared

### Requirement: The repository root holds no generated or machine-local files

Logs, editor metadata and OS metadata SHALL NOT be present in the repository root.

#### Scenario: No debug log in the root

- **WHEN** the repository root is listed
- **THEN** no `firebase-debug.log` is present

#### Scenario: No OS metadata in the root

- **WHEN** the repository root is listed
- **THEN** no `.DS_Store` is present

### Requirement: Working tree status is a meaningful signal

`git status` on a clean checkout SHALL be empty, so that any entry represents a real, reviewable change.

#### Scenario: A clean checkout reports nothing

- **WHEN** `git status --porcelain` is run on a fresh checkout with no edits
- **THEN** it produces no output

#### Scenario: Build artifacts do not appear

- **WHEN** a build or a fastlane run regenerates its artifacts
- **THEN** those artifacts do not appear as untracked files

#### Scenario: Screenshots have a decided status

- **WHEN** `brainy-app/screenshots/review_*.png` are inspected
- **THEN** they are either tracked with a documented purpose or ignored, and not left untracked
