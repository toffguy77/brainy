## ADDED Requirements

### Requirement: Plans describe what the code actually does

Every factual claim in `docs/plans/features/`, `docs/plans/ops/` and `CLAUDE.md` SHALL be true of the code at the commit where it appears. Plans describe present behaviour, not intent or history. Known gaps between intended and actual behaviour SHALL be stated as such in the plan rather than described as working.

#### Scenario: No claim references a non-existent branch

- **WHEN** the plans and `CLAUDE.md` are searched for git branch references
- **THEN** every branch named exists, or there is none

#### Scenario: No claim references a deleted file

- **WHEN** every file path named in the plans and `CLAUDE.md` is resolved against the repository
- **THEN** each one exists

#### Scenario: Screen descriptions follow the widgets

- **WHEN** a plan describes a screen's layout or navigation (onboarding pages, character screen, home picker)
- **THEN** it matches the widget code — e.g. onboarding has `AppConstants.onboardingPageCount` = 6 pages in 6 page files with swipe disabled, and the home picker lists `AppConstants.gridSizesForMode(mode)`

#### Scenario: Known gaps are labelled

- **WHEN** code falls short of a rule a plan states (for example ICU plurals in ARB strings)
- **THEN** the plan names the affected keys as known debt instead of claiming the rule is met

### Requirement: Identifiers in plans match identifiers in code

Where a plan names a constant, key, enum value, Hive field or external identifier, it SHALL use the exact value from the code.

#### Scenario: Achievement identifiers match

- **WHEN** the achievement table in `progress-tracking.md` is compared against `AchievementId` and `AchievementDef.idString`
- **THEN** the sets are identical (10 values, `first_game` … `coin_hoarder`)

#### Scenario: Leaderboard identifiers match

- **WHEN** the leaderboard IDs in `leaderboards.md` are compared against `GameServicesService`
- **THEN** they match exactly: `brainy_weekly_xp` and `brainy_best_time_{N}x{N}`, with only classic records submitted to the best-time boards

#### Scenario: Hive models match

- **WHEN** the model descriptions are compared against the adapters in `lib/models/`
- **THEN** typeIds and field lists match: `GameSession` 0, `UserProgress` 1 (fields 0–12), `CharacterData` 2 (fields 0–8, including `equippedCape`)

#### Scenario: Every named identifier exists

- **WHEN** each backticked identifier in the feature plans and `CLAUDE.md` is grepped in `brainy-app/lib`, `brainy-app/l10n` and `.github`
- **THEN** it is found, tool names such as `gen_l10n` excepted

### Requirement: Plans describe the technologies actually in use

Plans SHALL NOT describe storage, tooling, platforms or integrations the project does not use.

#### Scenario: Storage description is accurate

- **WHEN** `CLAUDE.md` describes data persistence
- **THEN** it states that Hive is the only store, Firestore is not used and leaderboards go through Game Center

#### Scenario: Toolchain description is accurate

- **WHEN** `CLAUDE.md` describes providers, Hive adapters and localization
- **THEN** it does not mention a code generator other than `gen_l10n`, and places ARB sources in `brainy-app/l10n/` and generated code in `brainy-app/lib/l10n/`

#### Scenario: Platform and monetization are accurate

- **WHEN** the plans and `CLAUDE.md` describe platform and pricing
- **THEN** they state iOS only, completely free, no analytics, Crashlytics as the only Firebase product

#### Scenario: CI description matches the workflows

- **WHEN** `ci-cd.md` is compared against `.github/workflows/` and `brainy-app/ios/fastlane/Fastfile`
- **THEN** every workflow named exists with the trigger, gate and steps described, every existing workflow and lane is documented, and the secrets table lists exactly the secrets the workflows read

#### Scenario: Store metadata matches the repository

- **WHEN** `appstore-metadata.md` is compared against `brainy-app/ios/fastlane/metadata/`, `screenshots/` and `scripts/compose_screenshots.py`
- **THEN** names, keywords, captions and screenshot sizes (6.7" 1290x2796, 6.5" 1242x2688, iPad 13" 2048x2732) match, and settings kept only in App Store Connect are labelled as such

### Requirement: Plans for removed features are deleted

When a feature is removed, its plan SHALL be deleted rather than rewritten to describe its absence, and references to it SHALL be removed from other plans.

#### Scenario: The subscription plan is gone

- **WHEN** `docs/plans/` is listed and searched for `subscription`, `premium`, `RevenueCat`, `YooKassa`
- **THEN** `subscription.md` does not exist and no plan describes a paid tier

#### Scenario: The session time limit is gone

- **WHEN** `parent-panel.md` lists the parent settings
- **THEN** it does not describe a maximum session time, because the control was removed from the app

### Requirement: Plan accuracy is verified against code

Plans SHALL be checked against the code rather than assumed correct. Verification SHALL inspect the referenced identifiers, files and behaviour, not the plan alone; behaviour that is wrong in code SHALL be reported for a code change rather than papered over in prose.

#### Scenario: Claims are spot-checked in review

- **WHEN** `/review` runs on a diff that touches a plan
- **THEN** its checklist requires that every identifier, path, constant and key the plan names exists in code (`.claude/commands/review.md`)

#### Scenario: Code defects found during an audit are recorded

- **WHEN** an audit finds behaviour that only a code change can fix
- **THEN** the finding is recorded with file and line in the change's `design.md` and the plan describes the current behaviour
