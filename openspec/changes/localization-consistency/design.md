## Context

The ARB files are healthy: 244 keys each, verified identical between `app_ru.arb` and `app_en.arb`. The problems are entirely in code that bypasses them.

**Notification strings.** `NotificationService` holds two pools per language — seven motivational variants and seven streak-warning variants — selected by `dayOfYear % count` and switched by a locale parameter. Twenty-eight strings, none in ARB. This is the largest block of untranslated-by-the-system text in the app, and the one that blocks adding a third language most concretely.

**Paywall locale branching.** Three sites in `paywall_screen.dart` compare `languageCode == 'ru'` inline. `remove-monetization-go-free` deletes this file, so this deviation resolves itself; what remains is confirming the pattern exists nowhere else.

**Character name duplication.** Names exist in ARB and in `CharacterInfo.nameRu`/`nameEn`. Two sources for one string means they can silently disagree.

`docs/plans/features/localization.md` documents all three under "Особенности" — describing them as characteristics of the system rather than as defects. That framing is why they were never fixed.

## Goals / Non-Goals

**Goals:**
- One mechanism for user-facing text.
- Adding a locale means adding an ARB file and nothing else.
- The plan describes rules rather than cataloguing exceptions.

**Non-Goals:**
- Adding a third language. This change makes that possible; it does not do it.
- Retranslating existing strings. Text moves verbatim.
- Localizing non-user-facing strings — log messages, analytics event names, Hive keys.

## Decisions

**Indexed ARB keys for the notification pools.** ARB has no array type. The alternatives are numbered keys (`notificationMotivation1` … `notificationMotivation7`) or ICU `select` with a synthetic argument. Numbered keys are chosen: they read clearly in the ARB, translate individually, and keep the selection rule (`dayOfYear % count`) in Dart where it already is and where it is testable.

*Alternative considered:* a single ARB key holding a delimited list. Rejected — it defeats per-string translation tooling and turns a translator's job into string surgery.

**Require equal variant counts across locales.** The index is computed once and used for whichever locale is active. If ru had seven variants and en had five, an index of six would be out of range. Stating this as a requirement makes an implicit coupling explicit.

**Resolve the character-name duplication toward `CharacterInfo`, not ARB.** Character names are data belonging to a character definition that already carries id, colour, unlock type and asset path. Splitting one field of that record into ARB while the rest stays in Dart is the awkward option. Removing the duplicate ARB keys and reading names from `CharacterInfo` keeps the record whole.

*Alternative considered:* keep ARB as the source and drop `nameRu`/`nameEn`. Defensible on the "all text in ARB" rule read literally, and would matter more if character names were ever translated by an outside translator. Either resolution satisfies the single-source requirement; this is the one to revisit if translation tooling is ever brought in.

**Do not build automated key-parity checking here.** The check is a few lines of script and belongs with the CI gate; this change requires that parity be verified, and `ci-quality-gate` is the right place to automate it. Stating the requirement without pretending it is enforced keeps the specification honest.

**Let `remove-monetization-go-free` handle the paywall.** Fixing locale branching in a file scheduled for deletion is wasted work.

## Risks / Trade-offs

- **Twenty-eight new ARB keys is a large, mechanical diff** → Unavoidable; the strings must live somewhere. Move them verbatim so the diff is pure relocation and easy to review.
- **Numbered keys are ugly** → Accepted. ARB has no arrays, and the alternatives are worse.
- **Removing duplicate character-name keys breaks a caller** → The compiler catches every one.
- **Notification tests may assert on literal strings** → Update them to assert against the localizations, which is a better test anyway.

## Migration Plan

1. Land `remove-monetization-go-free`, removing the paywall branching.
2. Move the 28 notification strings into both ARB files as numbered keys; regenerate localizations.
3. Update `NotificationService` to resolve strings through localizations, keeping `dayOfYear % count`.
4. Verify a notification renders correctly in both locales.
5. Resolve the character-name duplication in one direction; update callers.
6. Verify ru/en key parity.
7. Rewrite `localization.md`.

**Rollback:** each step is an independent revert. Nothing touches persisted user data.

## Open Questions

- Should `NotificationService` receive a `AppLocalizations` instance, or resolve one from a stored locale? It runs outside a widget tree when scheduling from a background context, which may constrain the answer.
- Should key parity be enforced in CI as part of `ci-quality-gate`?
- Is a third language actually planned? It affects how much the character-name decision matters.
