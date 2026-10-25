Legend: `[x]` done (evidence cited), `[~]` dropped / not applicable (reason given), `[ ]` open — only for
work that needs a physical device. Paths are relative to `brainy-app/` unless they start with `docs/`,
`.github/` or `openspec/`. Verified against branch `chore/finish-audit-changes` at `1e1e279`.

## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed and `paywall_screen.dart` is gone — no `*paywall*` file exists under `lib/`, and `lib/features/` has no `subscription` directory (commits f0e1ec8, faf276b)
- [x] 1.2 Grep the codebase for `languageCode ==` and confirm no manual locale branching remains — the only `== 'ru'` in `lib/` (excluding generated `lib/l10n/`) is `AppConstants.alphabetFor` (`lib/constants/app_constants.dart:194`), which picks game data (the letters-mode alphabet), not a translation. Other `languageCode` reads pass the code on (`lib/features/game/screens/game_screen.dart:44`, `lib/main.dart:74`, `lib/shared/services/notification_service.dart:113`) or are unused (`lib/features/progress/screens/progress_screen.dart:21`)
- [x] 1.3 Record the baseline: ru and en ARB key counts match — at f0e1ec8 `app_en.arb` had 216 message keys / 246 entries. At HEAD both files have 291 entries: 255 message keys, 35 `@` metadata entries and `@@locale`. The key sets are identical, metadata included

## 2. Move notification strings into ARB

- [x] 2.1 Decide how `NotificationService` obtains localizations when scheduling outside a widget tree — `AppLocalizations.delegate.load(Locale(language))`, where `language = AppConstants.resolveLanguage(platformDispatcher.locale.languageCode)` (`lib/shared/services/notification_service.dart:112-115`). `resolveLanguage` returns `ru` for `ru` and `en` for anything else (`lib/constants/app_constants.dart:185-191`). The app uses the same rule in `localeResolutionCallback` (`lib/main.dart:73-74`)
- [x] 2.2 Add seven motivational variants as numbered keys to `app_ru.arb` and `app_en.arb` — `notificationMotivation1..7` in both files (from `l10n/app_ru.arb:469`, `l10n/app_en.arb:469`)
- [x] 2.3 Add seven streak-warning variants as numbered keys to both files, preserving the `{count}` placeholder — `notificationStreak1..7`, each with `@` metadata for `count` (from `l10n/app_ru.arb:470`)
- [x] 2.4 Move all strings verbatim so the diff is pure relocation — the wording matches the old literals (for example `'Время потренировать мозг!'` in `NotificationService` at f0e1ec8^ is now `l10n/app_ru.arb:469`). One intended change: the `{N}` token became the ICU placeholder `{count}`
- [x] 2.5 Regenerate localizations — `lib/l10n/app_localizations*.dart` define `notificationMotivation1..7` and `notificationStreak1..7(int)`. `notification_service.dart:154-174` compiles against them
- [x] 2.6 Update `NotificationService` to resolve strings through localizations, keeping the deterministic per-day selection — `motivationVariant` / `streakVariant` (`notification_service.dart:154-174`). The selection rule is not `dayOfYear % count` (the old code used local `DateTime.now().difference(DateTime(2024)).inDays`). It is UTC calendar days since 2024-01-01, mod `variantCount` (`notification_service.dart:144-152`), so a DST change cannot shift it. Title is `l10n.appName` (`notification_service.dart:123`)
- [x] 2.7 Confirm both pools have equal variant counts in every locale — a single `variantCount = 7` (`notification_service.dart:144`). `test/services/notification_text_test.dart:16-28,78+` checks every index in both locales
- [x] 2.8 Update any notification test that asserted on literal strings — `test/services/notification_text_test.dart` loads `AppLocalizations` for ru/en and asserts through it. `test/services/reminder_plan_test.dart:56-64,76-80` pins the UTC index and the `resolveLanguage` fallback

## 3. Resolve the character name duplication

- [x] 3.1 Choose the single source — **ARB** (this reverses the earlier "`CharacterInfo` recommended" choice, to follow the CLAUDE.md rule "all text via ARB"). `CharacterInfo` keeps only id and data. `name/description/unlockCondition(l10n)` pick `character{Id}Name/Description/Unlock` by id (`lib/features/character/data/characters_data.dart:23-49`). Accessories work the same way: `AccessoryInfo.name(l10n)` → `accessory{Id}Name` (`lib/models/accessory.dart:25-40`)
- [x] 3.2 Remove the duplicate definitions from the other source — `CharacterInfo` has no ru/en text fields (`characters_data.dart:6-20`), and nothing in `lib/` reads a `nameRu`/`nameEn`-style field. The Hive model `CharacterData` still has `nameRu/nameEn` (`lib/models/character.dart:5-6`) so the stored format stays compatible. They are written with the id and never read (`lib/features/character/providers/character_provider.dart:22-26`), so they hold no display text
- [x] 3.3 Update all callers — 14 call sites in `lib/` use `.name(l10n)` / `.description(l10n)` / `.unlockCondition(l10n)` (e.g. `lib/features/progress/screens/progress_screen.dart:364,390`). `integration_test/screenshot_test.dart` was updated in 4111600
- [x] 3.4 Confirm character names render correctly in both locales — `test/character/character_unlock_test.dart:62-77` loads ru and en and asserts that name, description and unlock text are non-empty and not the id fallback. `test/character/accessory_shop_test.dart:51-53` does the same for accessories

## 4. Verify

- [x] 4.1 Confirm ru and en ARB key sets are identical — same 291 keys, metadata included. The CI step `ARB key parity (ru vs en)` diffs every key except `@@`-prefixed ones (`.github/workflows/ci.yml:37-41`)
- [x] 4.2 Grep `lib/` for user-facing string literals and confirm none remain from the original scope — no Cyrillic outside `lib/l10n/` except the alphabet (`app_constants.dart:170-175`). The old literals `'Найдено'`, `'Найди'` and `'сек'` are now `gameFoundProgress` (`lib/features/game/screens/game_screen.dart:161`), `gameFind` (`lib/features/game/widgets/game_header.dart:85`) and `shareSeconds` (`lib/features/parent/screens/parent_dashboard_screen.dart:606`, `lib/features/parent/widgets/share_card.dart:171`, `progress_screen.dart:798`). The share-card title is an ICU plural (`l10n/app_ru.arb:180`). Legal URLs are `privacyPolicyUrl`/`termsUrl` (`lib/features/parent/screens/parent_settings_screen.dart:274,279`). Remaining minor gaps are listed in `proposal.md` under "Known gaps", outside this change
- [ ] 4.3 Manual (device): set the device language to Russian, enable reminders, skip training, let the reminder fire. Check that the title is "Brainy" and the body is a Russian `notificationMotivation*` variant, or `notificationStreak*` with the streak number when streak > 2. Repeat in English and in an unsupported language such as German (expect English)
- [x] 4.4 Run `flutter analyze` and `flutter test` — CI runs both (`.github/workflows/ci.yml:53-56`, `flutter analyze --fatal-infos`). They were not re-run during this audit, which was read-only

## 5. Correct the documentation

- [x] 5.1 Rewrite `docs/plans/features/localization.md` to describe one consistent mechanism — the "Правила" section (`localization.md:31-46`) covers ARB-only text, no locale branching, numbered variant pools, `delegate.load` + `resolveLanguage` for notifications, ICU plurals and CI parity
- [x] 5.2 Remove the section cataloguing deviations — the deviation entries (paywall branching, hardcoded notifications, duplicate names) are gone. A `## Особенности` heading is still there (`localization.md:60-68`), but it now lists design facts: ARB legal URLs, `appName` as the brand, the alphabet as game data, and the legacy Hive fields. None of these is a violation
- [x] 5.3 Decide whether ARB key parity should be enforced in CI via `ci-quality-gate` — **Decision: enforced in CI.** `.github/workflows/ci.yml:37-41` (added in 9180bab) runs `diff` on the sorted `jq` key lists of `app_ru.arb` and `app_en.arb`, `@`-metadata included and `@@locale` excluded, before Flutter setup. Any mismatch fails the job
