## ADDED Requirements

### Requirement: All user-facing text comes from ARB files

Every string shown to a user SHALL be defined in the ARB files (`l10n/app_ru.arb`, `l10n/app_en.arb`) and read through the generated `AppLocalizations`. Dart source SHALL NOT contain user-facing natural-language literals. Numbers, punctuation and pure formatting may be composed in Dart. Game data such as the letters-mode alphabet, and non-user-facing strings (logs, exception messages, Hive keys, routes, leaderboard ids), are out of scope.

#### Scenario: Notification text comes from ARB

- **WHEN** `NotificationService.rescheduleFromStorage` schedules a reminder
- **THEN** the title is `appName` and the body is one of `notificationMotivation1..7` or `notificationStreak1..7`, resolved from `AppLocalizations`
- **AND** `NotificationService` contains no literal title or body text

#### Scenario: Game hints and units come from ARB

- **WHEN** the game screen shows the next target and the found counter, or a session time is shown in seconds
- **THEN** the text comes from `gameFind`, `gameFoundProgress` and `shareSeconds`, not from the literals `'Найди'`, `'Найдено'` or `'сек'`

#### Scenario: Share card title is pluralized in ARB

- **WHEN** the parent share card shows the streak title
- **THEN** it uses the ICU plural key `parentShareCardTitle` with the day count

#### Scenario: Legal links come from ARB

- **WHEN** the parent opens the privacy policy or terms of use
- **THEN** the URL comes from `privacyPolicyUrl` or `termsUrl` for the active locale

#### Scenario: No Cyrillic outside generated code and game data

- **WHEN** `lib/` is searched for Cyrillic characters, excluding the generated `lib/l10n/`
- **THEN** the only matches are the letters-mode alphabet `AppConstants.alphabetRu` and its comment

### Requirement: Locale selection goes through the localization system

Code SHALL NOT compare the locale's language code to choose between translations. Choosing a translation is the job of `AppLocalizations`. A language code MAY be read to choose game data, such as the letters-mode alphabet via `AppConstants.alphabetFor`.

#### Scenario: No manual translation branching

- **WHEN** `lib/` is searched for `== 'ru'` or `languageCode ==`
- **THEN** no match chooses between two translated strings; the only match is `AppConstants.alphabetFor`

#### Scenario: Unsupported device languages fall back to English

- **WHEN** the device language is anything other than `ru` or `en`
- **THEN** `AppConstants.resolveLanguage` returns `en`, and `main.dart`'s `localeResolutionCallback` gives the app English

#### Scenario: Notifications use the same language rule as the app

- **WHEN** a reminder is scheduled outside the widget tree
- **THEN** `NotificationService` loads `AppLocalizations` for `AppConstants.resolveLanguage(platformDispatcher.locale.languageCode)`
- **AND** a device in Russian gets Russian text, and a device in any other language gets English text, the same as the app UI

### Requirement: Each string has exactly one definition

A user-facing string MUST be defined once, in ARB. The same text MUST NOT also exist in a Dart data structure.

#### Scenario: Character text has one source

- **WHEN** a character's name, description or unlock condition is shown
- **THEN** `CharacterInfo.name/description/unlockCondition(l10n)` returns `character{Id}Name/Description/Unlock` from ARB by id
- **AND** `CharacterInfo` has no locale-specific text fields

#### Scenario: Accessory names have one source

- **WHEN** an accessory name is shown
- **THEN** `AccessoryInfo.name(l10n)` returns `accessory{Id}Name` from ARB by id

#### Scenario: Legacy persisted fields carry no display text

- **WHEN** `CharacterData` records are created or read from Hive
- **THEN** the legacy `nameRu`/`nameEn` fields hold the character id only and are never used for display

#### Scenario: Every character and accessory has text in both locales

- **WHEN** ru and en localizations are loaded
- **THEN** every character's name, description and unlock text, and every accessory's name, is non-empty and is not the id fallback

### Requirement: Translation files stay in parity

`app_ru.arb` and `app_en.arb` MUST define the same set of keys, including `@` metadata entries. Only `@@`-prefixed file attributes such as `@@locale` are excluded. CI MUST fail when the sets differ.

#### Scenario: Key sets match

- **WHEN** the keys of `app_ru.arb` and `app_en.arb` are compared, excluding `@@`-prefixed entries
- **THEN** they are identical

#### Scenario: Parity is enforced in CI

- **WHEN** a pull request or push runs `.github/workflows/ci.yml`
- **THEN** the step "ARB key parity (ru vs en)" diffs the sorted key lists of both files and fails the job on any difference, before analyze and test

### Requirement: Variant pools are expressed in ARB

Where the app picks among several phrasings, every variant SHALL be its own numbered ARB key. The choice SHALL be a deterministic index computed in Dart, and every locale MUST define the same number of variants.

#### Scenario: Notification variants are numbered ARB keys

- **WHEN** the notification service picks a motivational or streak variant
- **THEN** it maps an index in `0..variantCount-1` to `notificationMotivation{n}` or `notificationStreak{n}(count)`, with `variantCount = 7`

#### Scenario: The index is stable per calendar day

- **WHEN** `variantIndexFor` is called for two times on the same local calendar date
- **THEN** it returns the same index, computed as UTC calendar days since 2024-01-01 mod `variantCount`
- **AND** consecutive dates give different indices, and a DST transition does not change the result

#### Scenario: Variant counts match across locales

- **WHEN** every index from 0 to `variantCount - 1` is resolved in ru and in en
- **THEN** each returns a non-empty string, and streak variants substitute `{count}` with no raw placeholder left

### Requirement: Documentation describes rules, not permanent exceptions

`docs/plans/features/localization.md` SHALL describe how localization works and SHALL NOT record violations of its own rules as settled facts.

#### Scenario: The plan states the rules

- **WHEN** `localization.md` is read
- **THEN** it states: ARB-only text, no locale branching, numbered variant pools with equal counts, notification localization via `delegate.load` and `resolveLanguage`, ICU plurals, and CI-enforced parity

#### Scenario: The plan lists no standing violations

- **WHEN** the plan's notes section ("Особенности") is read
- **THEN** it contains only design facts (ARB legal URLs, brand `appName`, alphabet as game data, legacy Hive fields) and no entry that describes text bypassing ARB or a locale comparison choosing a translation
