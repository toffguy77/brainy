## Decision

- **Notification text:** numbered ARB keys (`notificationMotivation1..7`, `notificationStreak1..7`). The title is `appName`. Strings are resolved with `AppLocalizations.delegate.load(Locale(AppConstants.resolveLanguage(deviceLanguage)))`, because scheduling runs outside the widget tree.
- **Locale rule:** `resolveLanguage`: `ru` → ru, anything else → en (`supportedLanguages = ['en', 'ru']`, fallback `first`). The app's `localeResolutionCallback` (`main.dart:73-74`) and `NotificationService` (`notification_service.dart:112-115`) both use it, so a reminder and the UI never disagree on language.
- **Variant selection:** `variantIndexFor(day)` = whole UTC calendar days from 2024-01-01 to `day`'s date, mod `variantCount` (7) (`notification_service.dart:144-152`). This replaces the draft's `dayOfYear % count` wording, which never matched the code. The pre-change code used `DateTime.now().difference(DateTime(2024)).inDays % length`: local time, including the time of day, so a DST shift could move it. The new code uses calendar dates in UTC, so a DST shift cannot produce a 23-hour "day".
- **Character and accessory text: ARB is the single source (reversed).** The draft chose `CharacterInfo`. That was reversed to satisfy CLAUDE.md "all text via ARB": names, descriptions and unlock conditions, plus accessory names, are ARB keys looked up by id.
- **Key parity: enforced in CI (reversed).** The draft said not to automate parity in this change. A CI step was added (`.github/workflows/ci.yml:37-41`, 9180bab). It diffs the full key lists, `@` metadata included, `@@locale` excluded.

## Outcome

Implemented in 5cbd984, 4111600 and 9180bab. Both ARB files have 291 entries: 255 message keys, 35 metadata entries and `@@locale`. The key sets are identical. The paywall is gone. The only `== 'ru'` branch left in `lib/` is the letters-mode alphabet (`AppConstants.alphabetFor`), which is game data. Tests cover both locales for notification variants (`test/services/notification_text_test.dart`), the UTC index and the language fallback (`test/services/reminder_plan_test.dart`), and character/accessory text (`test/character/*`). One device check is still open (tasks 4.3). Known gaps outside this change, mainly missing Russian plurals, are listed in `proposal.md`.

## Context

At draft time the ARB files were in parity, and the problems were in code that bypassed them.

**Notification strings.** `NotificationService` held two pools per language (seven motivational variants and seven streak warnings), picked by a per-day index and switched by a locale parameter. That was 28 strings, none in ARB.

**Paywall locale branching.** `paywall_screen.dart` compared `languageCode == 'ru'` inline. `remove-monetization-go-free` deleted the file.

**Character name duplication.** Names existed in ARB and in `CharacterInfo.nameRu`/`nameEn`.

`docs/plans/features/localization.md` listed all three under "Особенности" as properties of the system rather than defects.

## Goals / Non-Goals

**Goals:**
- One mechanism for user-facing text.
- Adding a locale means adding an ARB file, plus adding its code to `AppConstants.supportedLanguages` (and an alphabet, if the letters mode should support it).
- The plan describes rules rather than cataloguing exceptions.

**Non-Goals:**
- Adding a third language.
- Retranslating existing strings. Text moved verbatim. The one change was the `{N}` token becoming the ICU placeholder `{count}`.
- Localizing non-user-facing strings: log and exception messages, analytics event names, Hive keys, route paths, Game Center leaderboard ids.

## Decisions (as drafted, with resolution)

**Indexed ARB keys for the notification pools.** ARB has no array type. Numbered keys read clearly, can be translated one at a time, and keep the selection rule in Dart, where it can be tested. *Kept.* A single delimited key was rejected: it defeats per-string translation tooling.

**Require equal variant counts across locales.** The index is computed once and used for whichever locale is active. *Kept:* there is one `variantCount = 7`, and each locale's switch covers all seven keys.

**Resolve the character-name duplication toward `CharacterInfo`.** *Reversed → ARB.* The draft argued for keeping the character record whole in Dart. The project rule in CLAUDE.md ("All text localized via ARB files") takes precedence, and keeping text in ARB means a new locale needs no Dart change for character copy. `CharacterInfo` keeps id, unlock rule, asset and colour. Text is looked up by id. The legacy Hive fields `CharacterData.nameRu/nameEn` stay so the stored format remains readable. They are written with the id and never read.

**Do not build automated key-parity checking here.** *Reversed → enforced in CI.* The check was only a few lines of `jq`/`diff`, so it was added straight to `ci.yml`.

**Let `remove-monetization-go-free` handle the paywall.** *Kept;* the file is gone.

## Risks / Trade-offs

- **Large mechanical ARB diff.** Accepted. Strings moved verbatim.
- **Numbered keys are ugly.** Accepted.
- **Removing character text fields breaks callers.** The compiler caught them. Callers now use `.name(l10n)` / `.description(l10n)` / `.unlockCondition(l10n)`.
- **Notification tests asserting on literals.** They now load `AppLocalizations` for each locale.
- **Verbatim move kept grammar bugs.** The Russian streak variants say `{count} дней` with no ICU plural ("Стрик 3 дней"). Recorded as a known gap in `proposal.md`; this change does not fix it.

## Migration Plan

1. Land `remove-monetization-go-free`. Done.
2. Move the 28 notification strings into both ARB files; regenerate. Done.
3. Resolve notification strings through localizations with the UTC day index. Done.
4. Check a notification on a device in each locale. Open, manual (tasks 4.3).
5. Move character/accessory text to ARB; update callers. Done.
6. Check ru/en key parity, enforced in CI. Done.
7. Rewrite `localization.md`. Done.

**Rollback:** each step can be reverted on its own. No persisted user data changes; the Hive `CharacterData` layout is unchanged.

## Open Questions (resolved)

- *How does `NotificationService` get localizations?* `AppLocalizations.delegate.load()` with the device language from `platformDispatcher.locale`, mapped through `resolveLanguage`.
- *Enforce parity in CI?* Yes, `ci.yml` step "ARB key parity (ru vs en)".
- *Is a third language planned?* The repository shows no plan for one. It no longer affects the character decision, since text is in ARB.
