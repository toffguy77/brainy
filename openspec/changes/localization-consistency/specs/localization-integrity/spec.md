## ADDED Requirements

### Requirement: All user-facing text comes from ARB files

Every string shown to a user SHALL be defined in the ARB files and accessed through the generated localizations. No user-facing string SHALL be a literal in Dart source.

#### Scenario: Notification text comes from ARB

- **WHEN** a reminder notification is scheduled
- **THEN** its title and body come from the generated localizations, not from literals in `NotificationService`

#### Scenario: No hardcoded strings remain in services

- **WHEN** `lib/shared/services/` is searched for user-facing string literals
- **THEN** none are found

### Requirement: Locale selection goes through the localization system

Code SHALL NOT branch on `Localizations.localeOf(context).languageCode` to choose between translations. Selecting a translation is the localization system's responsibility.

#### Scenario: No manual locale branching

- **WHEN** the codebase is searched for `languageCode ==`
- **THEN** no match selects between two hardcoded translations

#### Scenario: Locale-specific URLs remain acceptable

- **WHEN** a locale-specific legal URL is chosen
- **THEN** it is selected through an ARB key rather than an inline locale comparison

### Requirement: Each string has exactly one definition

A user-facing string SHALL be defined once. The same text SHALL NOT exist in both an ARB file and a Dart data structure.

#### Scenario: Character names have one source

- **WHEN** a character's display name is rendered
- **THEN** it comes from a single definition, and the alternative source has been removed

#### Scenario: No silent divergence is possible

- **WHEN** a character name is changed in its source of truth
- **THEN** no second copy remains that could still show the old value

### Requirement: Translation files stay in parity

Every locale's ARB file SHALL define the same set of keys. A key present in one and absent from another SHALL fail verification.

#### Scenario: Key sets match

- **WHEN** the key sets of `app_ru.arb` and `app_en.arb` are compared
- **THEN** they are identical, ignoring `@`-prefixed metadata

#### Scenario: Parity is checked, not assumed

- **WHEN** an ARB file is modified
- **THEN** key parity is verified before the change is accepted

### Requirement: Variant pools are expressed in ARB

Where the app selects among several phrasings, all variants SHALL live in ARB with a deterministic selection rule in code.

#### Scenario: Notification variants are ARB keys

- **WHEN** the notification service selects among its motivational or streak variants
- **THEN** each variant is an ARB key and the selection index is computed in Dart

#### Scenario: Variant counts match across locales

- **WHEN** the variant pools are compared between locales
- **THEN** each pool has the same number of variants, so the selection index is valid in every locale

### Requirement: Documentation describes rules, not permanent exceptions

`docs/plans/features/localization.md` SHALL describe how localization works, and SHALL NOT record known violations as settled facts.

#### Scenario: The plan lists no standing deviations

- **WHEN** `localization.md` is read after this change
- **THEN** it describes a single consistent mechanism with no "deviation from the standard approach" section
