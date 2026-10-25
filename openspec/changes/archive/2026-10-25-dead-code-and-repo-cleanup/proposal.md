## Decision

Implemented on branch `chore/finish-audit-changes` (commits `f0e1ec8..HEAD`). Everything dead was deleted rather than wired in; the empty animations declaration was removed; the review screenshots are ignored, not committed.

## Outcome

- `ParentScreen` (`lib/features/parent/screens/parent_screen.dart`) deleted in `f0e1ec8`, taking the only hardcoded label (`Text('Родитель')`) with it. No `ParentScreen` or `Родитель` remains in `lib/`, `test/` or `integration_test/`.
- More dead Dart files deleted in `9180bab`: `lib/shared/services/firebase_service.dart`, `lib/shared/widgets/brainy_button.dart`, `lib/shared/widgets/brainy_card.dart`, `lib/constants/app_text_styles.dart`. (The `faf276b` message lists them, but the deletions are in `9180bab`.)
- 12 unused ARB keys removed in `faf276b`. `app_en.arb` and `app_ru.arb` now have the same 255 keys, and every one is used in `lib/` or `test/`.
- `assets/animations/` removed from `pubspec.yaml` in `faf276b`, and the directory no longer exists. It was leftover scaffolding: `lottie` was added in the scaffold commit `441c4c6`, removed in `2b8bf4a`, and `package:lottie` was never imported.
- `firebase-debug.log` and `.DS_Store` are gone from the root and covered by `.gitignore` (`*.log`, `.DS_Store`). The unused `firebase.json` / Firestore config is gone too.
- Fastlane `README.md` / `report.xml` are ignored (`.gitignore:35-36`, from `secrets-hygiene`).
- `brainy-app/screenshots/review_*.png` are ignored (`.gitignore:44-45`). They are App Review evidence of the paywall that was removed and are kept locally only.
- The `/review` checklist (`.claude/commands/review.md:29-31`) now checks plan identifiers, unreferenced Dart files and decorative controls.
- `git status --porcelain` is empty on the branch.
- Re-audit: all 65 Dart files under `lib/` can be reached by imports from `lib/main.dart`.

Still unused, outside this change's file-level rule (reported only, not fixed):
- `AppColors.backgroundGradient` — `brainy-app/lib/constants/app_colors.dart:23`
- `AppConstants.ageOptions` — `brainy-app/lib/constants/app_constants.dart:117`. `age_page.dart:16-18` repeats the literals inline.
- `AppConstants.goalOptions` — `brainy-app/lib/constants/app_constants.dart:118`. `goals_page.dart:17-20` repeats the literals inline.

## Why

Dead code and repository noise are each trivial, but together they do damage. They make `git status` unreadable, they make grep results untrustworthy, and they blur the line between code that is unused and code that is just not referenced yet.

`ParentScreen` was never imported and had no route, yet it held the only hardcoded Russian string in `lib/`. It broke the "all text localized" rule where nobody could see it. Other noise: `assets/animations/` was declared but empty, a 1.3 MB `firebase-debug.log` and a `.DS_Store` sat in the root, and untracked fastlane artifacts and review screenshots showed up in every status check.

## What Changes

- `ParentScreen` and four other unreferenced Dart files are deleted, along with unused ARB keys.
- The `assets/animations/` declaration is removed from `pubspec.yaml`.
- Stray root files (`firebase-debug.log`, `.DS_Store`) are removed and ignored.
- Fastlane artifacts are ignored (handled in `secrets-hygiene`).
- `brainy-app/screenshots/review_*.png` are ignored and kept locally.
- New rule: any Dart file in `lib/` that nothing imports is either wired up or deleted. The `/review` checklist enforces it.

## Capabilities

### New Capabilities
- `repository-hygiene`: what may exist in the tree, and the standard for unreferenced code.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for repository structure. -->

## Impact

- `brainy-app/lib/features/parent/screens/parent_screen.dart`, `lib/shared/services/firebase_service.dart`, `lib/shared/widgets/brainy_button.dart`, `lib/shared/widgets/brainy_card.dart`, `lib/constants/app_text_styles.dart` — deleted.
- `brainy-app/l10n/app_{en,ru}.arb` and the generated `lib/l10n/app_localizations*.dart` — unused keys removed.
- `brainy-app/pubspec.yaml` — the `assets/animations/` line removed.
- `.gitignore` — `brainy-app/screenshots/review_*.png`. `*.log`, `.DS_Store` and the fastlane entries were already there.
- `.claude/commands/review.md` — three new checklist items.
- `git status` is a meaningful signal again.
