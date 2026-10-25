## ADDED Requirements

### Requirement: Plans describe what the code actually does

Every factual claim in `docs/plans/` and `CLAUDE.md` SHALL be true of the code at the commit where it appears. Plans describe present behaviour, not intent or history.

#### Scenario: Every audited claim is corrected

- **WHEN** the ten discrepancies identified in the 2026-08-01 audit are re-checked
- **THEN** each documented claim matches the code, or the code has been changed to match the documented intent

#### Scenario: No claim references a non-existent branch

- **WHEN** the plans and `CLAUDE.md` are searched for git branch references
- **THEN** every branch named exists, or the reference is removed

#### Scenario: No claim references a deleted file

- **WHEN** the plans are searched for file paths
- **THEN** every path referenced exists

### Requirement: Identifiers in plans match identifiers in code

Where a plan names a constant, key, enum value or external identifier, it SHALL use the exact value from the code.

#### Scenario: Achievement identifiers match

- **WHEN** the achievement list in `progress-tracking.md` is compared against `AchievementId`
- **THEN** the sets are identical

#### Scenario: Leaderboard identifiers match

- **WHEN** the leaderboard IDs in `leaderboards.md` are compared against `game_services_service.dart`
- **THEN** they match exactly, including the `brainy_` prefix

#### Scenario: Model fields match

- **WHEN** the `CharacterData` fields listed in `character-system.md` are compared against `models/character.dart`
- **THEN** every persisted field is listed, including `equippedCape`

### Requirement: Plans describe the technologies actually in use

Plans SHALL NOT describe storage, tooling or platform integrations the project does not use.

#### Scenario: Storage description is accurate

- **WHEN** `CLAUDE.md` describes data persistence
- **THEN** it does not claim Firestore stores leaderboard scores, since leaderboards use Game Center and `lib/` contains no Firestore usage

#### Scenario: Toolchain description is accurate

- **WHEN** `CLAUDE.md` describes code generation
- **THEN** it does not instruct running a generator the project does not use

#### Scenario: CI description matches the workflows

- **WHEN** `ci-cd.md` is compared against `.github/workflows/`
- **THEN** every workflow named exists with the trigger described, and every existing workflow is documented

### Requirement: Plans for removed features are deleted

When a feature is removed, its plan SHALL be deleted rather than rewritten to describe its absence.

#### Scenario: The subscription plan is gone

- **WHEN** a feature is removed from the product
- **THEN** its plan file is deleted, and references to it in other plans are removed

### Requirement: Documented behaviour is implemented or removed

A plan SHALL NOT describe user-facing behaviour that the code does not implement. Either the code implements it, or the plan stops claiming it.

#### Scenario: The session time limit claim is resolved

- **WHEN** `parent-panel.md` describes the maximum session time control
- **THEN** either the limit is enforced by the game, or the control and its description are removed

### Requirement: Plan accuracy is verified against code

Plans SHALL be checked against the code rather than assumed correct. Verification SHALL be by inspecting the referenced identifiers and files, not by reading the plan alone.

#### Scenario: Claims are spot-checked when a plan is updated

- **WHEN** a plan is updated after an implementation change
- **THEN** the identifiers, file paths and technologies it names are confirmed against the code
