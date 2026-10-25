## Outcome

Implemented on branch `chore/finish-audit-changes`, mainly in 5cbd984 (notifications, game UI strings) and 4111600 (characters, accessories, legal links), with the CI parity gate in 9180bab. All tasks are done except one device check (tasks 4.3).

- **Notifications:** 7 motivational and 7 streak variants per language live in ARB (`notificationMotivation1..7`, `notificationStreak1..7`). The title is `appName`. `NotificationService.rescheduleFromStorage` loads `AppLocalizations` for `AppConstants.resolveLanguage(device language)`: `ru` → ru, anything else → en. `main.dart` `localeResolutionCallback` uses the same rule. The variant index is UTC calendar days since 2024-01-01, mod 7.
- **Paywall locale branching:** gone with the paywall. The only `== 'ru'` left in `lib/` is `AppConstants.alphabetFor`, which picks game data, not a translation.
- **Characters — decision reversed:** the draft recommended `CharacterInfo` as the source of character names. It was reversed: **ARB is the single source**, to follow the CLAUDE.md rule "all text via ARB". Names, descriptions and unlock conditions are `character{Id}Name/Description/Unlock`. Accessory names are `accessory{Id}Name`. `CharacterInfo`/`AccessoryInfo` resolve them by id. The Hive model `CharacterData` keeps `nameRu/nameEn` only for storage compatibility. They are filled with the id and never read.
- **Beyond the original scope:** `'Найдено'`, `'Найди'` and `'сек'` became `gameFoundProgress`, `gameFind` and `shareSeconds`. The share-card title is an ICU plural (`parentShareCardTitle`). The legal links are ARB keys (`privacyPolicyUrl`, `termsUrl`). The share error is `shareFailed`.
- **Parity:** `app_ru.arb` and `app_en.arb` each have 291 entries (255 message keys, 35 `@` metadata entries, `@@locale`), with identical key sets. At f0e1ec8 en had 216 message keys / 246 entries. Parity is **enforced in CI** (`.github/workflows/ci.yml`, step "ARB key parity (ru vs en)"). This reverses the draft's "do not automate here".
- **Docs:** `docs/plans/features/localization.md` describes one mechanism and lists no standing violations.

### Known gaps (outside this change, not fixed)

- Russian plural forms are missing despite the plan's ICU-plural rule. `notificationStreak1/2/3/6/7` use `{count} дней` (`l10n/app_ru.arb:470,479,488,515,524`); with `streakWarningThreshold = 2` the first warning a user sees reads "Стрик 3 дней". `streakDays` "Серия {count} дней" (`app_ru.arb:87`, shown at `home_screen.dart:166`) has the same problem. So do `progressGoalStreak` (`app_ru.arb:229`; current streak goals 14/30/60 happen to read correctly) and `accessoriesNotEnoughCoinsMessage` (`app_ru.arb:114`). `progress_screen.dart:393` adds the bare word `parentDays` after a number.
- `'Brainy'` literal at `lib/features/onboarding/pages/welcome_page.dart:51`, although `appName` exists.
- Fallback player name `'Lv$userLevel'` at `lib/features/league/providers/league_provider.dart:106,140`. The simulated league names at `:130-131` are fixed data.
- The "XP" unit is built in Dart (`league_screen.dart:602`, `result_screen.dart:523,559,568`, `progress_screen.dart:193,203,372`). The ru ARB also uses "XP", so the text is consistent, but the unit is not in ARB.
- `DateFormat('dd.MM')` at `lib/features/parent/screens/parent_dashboard_screen.dart:552` is a fixed pattern that ignores the locale.

## Why

The project rule is that all user-facing text lives in ARB files. At the time of the draft the ARB files were in parity (ru and en had the same key set), but three kinds of text bypassed them, and `docs/plans/features/localization.md` recorded all three as known deviations that were never fixed.

`paywall_screen.dart` chose strings by checking the locale directly (`Localizations.localeOf(context).languageCode == 'ru'`). Every notification string (seven motivational and seven streak variants per language, 28 strings in total) was hardcoded in `NotificationService` and chosen by a locale parameter. Character names existed twice: in ARB and in `CharacterInfo.nameRu`/`nameEn`.

As a result, adding a third language was not just a matter of adding an ARB file, and the duplicate character names could silently drift apart.

## What Changes

- Notification strings move into ARB as numbered keys. Title and body are resolved through `AppLocalizations`.
- The paywall locale branching goes away with the paywall (`remove-monetization-go-free`). A grep confirms no similar branching remains.
- Character names, descriptions and unlock conditions, and accessory names, come from ARB only. The `CharacterInfo` text fields are removed.
- Remaining hardcoded game/share strings and the legal URLs move into ARB.
- A CI step checks ru/en ARB key parity.
- `docs/plans/features/localization.md` describes rules and no longer lists deviations as permanent facts.

## Capabilities

### New Capabilities
- `localization-integrity`: where user-facing text lives and how locale selection is performed.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for localization. -->

## Impact

- `lib/shared/services/notification_service.dart`: 28 hardcoded strings replaced by ARB lookups; title `appName`.
- `lib/constants/app_constants.dart`: `supportedLanguages`, `resolveLanguage`.
- `lib/main.dart`: `localeResolutionCallback` uses `resolveLanguage`.
- `lib/features/character/data/characters_data.dart`, `lib/models/accessory.dart`, `lib/features/character/data/accessories_data.dart`: text fields replaced by `(l10n)` lookups.
- `lib/features/game/*`, `lib/features/parent/*`, `lib/features/progress/screens/progress_screen.dart`: game hints, seconds unit, share title and legal links via ARB.
- `l10n/app_ru.arb`, `l10n/app_en.arb`: notification, character, accessory, game, share and legal-URL keys added (255 message keys each).
- `.github/workflows/ci.yml`: ARB parity step.
- `lib/features/subscription/screens/paywall_screen.dart`: deleted by `remove-monetization-go-free`.
- `docs/plans/features/localization.md`: rewritten.
