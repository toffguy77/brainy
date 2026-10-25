## Decision

Delete, don't wire in. Remove the empty animations declaration. Ignore the review screenshots and keep them locally. Enforce the unreferenced-file rule at review time, not with a lint.

## Outcome

Implemented in `f0e1ec8`, `9180bab` and `faf276b` on `chore/finish-audit-changes`. Verified read-only on 2026-10-25:

- `ParentScreen` is gone. `firebase_service.dart`, `brainy_button.dart`, `brainy_card.dart` and `app_text_styles.dart` are gone too (deleted in `9180bab`).
- Reachability walk over `import`/`export`/`part` from `lib/main.dart`: 65/65 Dart files under `lib/` are reachable.
- ARB: 255 keys in each locale, same key set in both, and each one is used in `lib/` or `test/`.
- The only literal `Text('…')` in `lib/` is the emoji `Text('🧠')` (`science_page.dart:28`).
- `pubspec.yaml` declares `characters`, `sounds`, `badges`, `leagues`, `icon` and `splash` under `assets/`. All six exist, and `assets/animations/` exists in neither the manifest nor the tree.
- `git check-ignore` confirms that `.gitignore` covers `firebase-debug.log`, `.DS_Store`, fastlane `README.md`/`report.xml` and all four `review_*.png`.
- `git status --porcelain` is empty.
- `/review` checklist lines 29-31: plan identifiers exist, no unreferenced Dart files, every control has a consumer.

Leftovers below file level, reported and not fixed here. They are outside this change's file-level standard:
- `AppColors.backgroundGradient` (`lib/constants/app_colors.dart:23`) — no usage.
- `AppConstants.ageOptions` (`lib/constants/app_constants.dart:117`) and `AppConstants.goalOptions` (`:118`) — no usage. `age_page.dart:16-18` and `goals_page.dart:17-20` repeat the same literals inline, which breaks the no-magic-strings rule.

## Context

The audit found several small hygiene defects, none of them urgent:

- `parent_screen.dart` defined `ParentScreen`, which nothing imported and no route registered. It was left over from an earlier structure: the parent feature is served by `parent_pin_screen`, `parent_dashboard_screen` and `parent_settings_screen`. It contained `Text('Родитель')`, the only hardcoded user-facing string in `lib/`.
- Scaffold-era files that nothing imported: `firebase_service.dart` (a one-line stub), `BrainyButton`, `BrainyCard`, `AppTextStyles`. There were also ARB keys that nothing read.
- `pubspec.yaml` declared `assets/animations/`, which was empty.
- `firebase-debug.log` (1.3 MB) and `.DS_Store` sat untracked in the repository root.
- Fastlane regenerates `README.md` and `report.xml` on every run, and both showed as untracked.
- Four `review_*.png` screenshots sat untracked in `brainy-app/screenshots/`.

What connects these is lost signal. If `git status` always lists irrelevant entries, nobody reads it, and a truly unexpected file goes unnoticed. Dead code works the same way: a rule violation survived because it lived where nobody looks.

## Goals / Non-Goals

**Goals:**
- Delete what is dead.
- Make `git status` empty on a clean checkout.
- Remove the last hardcoded string.

**Non-Goals:**
- Automated dead-code tooling.
- Restructuring the parent feature.
- Deciding whether animations belong in the product. This change only resolves the empty declaration.
- Unused class members and constants. The standard here is file-level. Member-level findings are listed under Outcome for follow-up.

## Decisions

**Delete `ParentScreen` and the other orphans rather than wire them in.** Three parent screens already cover that area, and the shared widgets duplicated styling the theme already provides. Deleting `ParentScreen` also removes the hardcoded string.

*Alternative considered:* keep it and localize the string. Rejected, because localizing a widget nobody renders produces nothing.

**Remove the `assets/animations/` declaration.** The directory was leftover scaffolding. `lottie` was declared in the first scaffold commit (`441c4c6`) and removed in `2b8bf4a`, and no file ever imported `package:lottie`. If animations come later, the declaration comes back with them.

**Ignore the review screenshots and keep them locally.** They show the onboarding paywall, the paywall and the premium lock: evidence for an App Review response about a paywall that no longer exists. The app is now completely free. Versioning images of removed UI would mislead, and the local copies are still there if an old dispute comes back. The ignore rule (`.gitignore:44-45`) carries a comment that states the purpose.

**Do not add a lint that fails on unreferenced files.** Dart has no reliable built-in check for this, and third-party tooling gives false positives on generated and platform-entry code. The rule is a `/review` checklist item, which is honest about what can actually be enforced.

**Run the audit after `remove-monetization-go-free`.** The monetization surface was removed first (`f0e1ec8`), so the audit ran against the smaller tree.

## Risks / Trade-offs

- **Deleting a file that turns out to be needed** → The compiler and CI (`flutter analyze --fatal-infos`, `flutter test`) would catch it immediately. None of the deleted files had importers.
- **Ignoring the screenshots loses versioned evidence** → Accepted. They document removed UI and are kept locally.
- **The "no unreferenced files" rule depends on reviewers** → Accepted and stated plainly. The rule is in the `/review` checklist.
- **Removing the asset declaration breaks an animation lookup** → Nothing in `lib/` or `test/` references `animations/`.

## Migration Plan

1. Delete `parent_screen.dart` and the other orphans. CI analyze and test stay green.
2. Remove the `assets/animations/` line from `pubspec.yaml`.
3. Remove `firebase-debug.log` and `.DS_Store`.
4. Confirm the fastlane ignore rules from `secrets-hygiene` are in place.
5. Ignore `brainy-app/screenshots/review_*.png`.
6. Verify `git status --porcelain` is empty.
7. Audit `lib/` for unreferenced files. Result: none.

**Rollback:** every deletion is an ordinary revert.

## Open Questions

None remain. Answers:

- *What do `review_*.png` document, and is it worth keeping?* App Review evidence of the removed paywall and premium lock. They are kept locally and ignored, not versioned.
- *Were animations ever planned, or is the directory leftover scaffolding?* Leftover scaffolding. `lottie` was declared and then dropped without ever being imported. Declaration and directory are both removed.
- *Should `/review` get an unreferenced-file check?* Yes, added (`.claude/commands/review.md:30`), with identifier and decorative-control checks next to it.
