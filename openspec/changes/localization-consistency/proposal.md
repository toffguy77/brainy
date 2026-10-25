## Why

The project rule is that all user-facing text lives in ARB files. The ARB files themselves are in good order — 244 keys in each of `app_ru.arb` and `app_en.arb`, with no key present in one and missing from the other. But three categories of text escape the system, and `docs/plans/features/localization.md` records all three as known deviations that were never corrected.

`paywall_screen.dart` picks strings by inspecting the locale directly (`Localizations.localeOf(context).languageCode == 'ru'`) at three call sites. Every notification string — seven motivational and seven streak variants per language, twenty-eight strings in total — is hardcoded in `NotificationService`, selected by a locale parameter. Character names exist twice: once in ARB, once in `CharacterInfo.nameRu`/`nameEn`.

The consequence is that adding a third language is not a matter of adding an ARB file. It requires finding and rewriting three separate ad-hoc mechanisms, and the duplicated character names can silently disagree with their ARB counterparts.

## What Changes

- Notification strings move into ARB files, with the variant pools expressed as indexed keys.
- The locale-branching in the paywall is removed. Note that `remove-monetization-go-free` deletes the paywall entirely, which resolves this deviation by deletion — so this change need only confirm no similar branching remains elsewhere.
- Character names come from a single source. Either `CharacterInfo` drops `nameRu`/`nameEn` and reads from ARB, or the ARB keys are removed and `CharacterInfo` is the source — but not both.
- The ru/en key-parity check becomes a verifiable step rather than an assumption.
- `docs/plans/features/localization.md` stops describing deviations as permanent facts.

## Capabilities

### New Capabilities
- `localization-integrity`: where user-facing text lives and how locale selection is performed.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for localization. -->

## Impact

- `lib/shared/services/notification_service.dart` — 28 hardcoded strings moved to ARB.
- `lib/features/character/data/characters_data.dart`, `lib/models/character.dart` — name duplication resolved.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — notification keys added, duplicate character keys possibly removed.
- `lib/features/subscription/screens/paywall_screen.dart` — deleted by `remove-monetization-go-free`.
- `docs/plans/features/localization.md` — accuracy restored.

Depends on `remove-monetization-go-free` for the paywall half.
