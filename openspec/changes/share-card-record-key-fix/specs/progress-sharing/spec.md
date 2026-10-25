## ADDED Requirements

### Requirement: The share card shows the player's real 5x5 best time

The shareable progress card SHALL display the stored personal best for the 5x5 classic grid, looked up with the canonical record key.

#### Scenario: A stored record is displayed

- **WHEN** the records box contains `classic_5` with value 22 and the parent taps Share
- **THEN** the card displays 22 seconds as the 5x5 best result

#### Scenario: Absence of a record is handled

- **WHEN** the records box contains no `classic_5` entry
- **THEN** the card renders its empty state without crashing

#### Scenario: Gorbov records do not substitute for classic

- **WHEN** the records box contains `gorbov_5` but no `classic_5`
- **THEN** the card renders the empty state, because the card reports the classic 5x5 result

### Requirement: Record lookups use the canonical key helper

Every consumer of the records map SHALL derive its key with `recordKey(mode, gridSize)`. No caller SHALL construct a key inline or index the map with a raw integer.

#### Scenario: No integer indexing of the records map

- **WHEN** the codebase is searched for indexing of the records map
- **THEN** every call site passes a key produced by `recordKey`

#### Scenario: Type mismatches are caught by analysis

- **WHEN** `flutter analyze` runs
- **THEN** it reports no `collection_methods_unrelated_type` finding

### Requirement: The share card is covered by a test

The card SHALL have an automated test asserting the values it renders, so a future key-format change fails loudly instead of silently emptying the card.

#### Scenario: Test asserts the rendered record

- **WHEN** the share card test suite runs against a seeded records box
- **THEN** it asserts the rendered 5x5 value matches the seeded record

#### Scenario: Test covers the empty state

- **WHEN** the test runs against an empty records box
- **THEN** it asserts the empty state renders without error
