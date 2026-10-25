## 1. Remove dead code

- [x] 1.1 Delete `brainy-app/lib/features/parent/screens/parent_screen.dart` — deleted in `f0e1ec8`; file absent
- [x] 1.2 Confirm nothing imported it and `flutter analyze` stays clean — no `ParentScreen` reference in `lib/`, `test/`, `integration_test/`; CI runs `flutter analyze --fatal-infos` (`.github/workflows/ci.yml:54`)
- [x] 1.3 Confirm no hardcoded `Text('...')` with linguistic content remains in `lib/` — only literal is `Text('🧠')` (`science_page.dart:28`)
- [x] 1.4 Delete other unreferenced scaffold files — `firebase_service.dart`, `brainy_button.dart`, `brainy_card.dart`, `app_text_styles.dart` deleted in `9180bab`
- [x] 1.5 Remove unused ARB keys — 12 keys removed in `faf276b`; en/ru now 255 identical keys, all used in `lib/` or `test/`

## 2. Resolve the empty asset declaration

- [x] 2.1 Determine whether animations were planned or the directory is scaffolding residue — residue: `lottie` added in `441c4c6`, removed in `2b8bf4a`, `package:lottie` never imported
- [x] 2.2 Remove `assets/animations/` from `pubspec.yaml`, or populate the directory — line removed in `faf276b`; directory absent
- [x] 2.3 Confirm no asset lookup fails — no `animations/` reference in `lib/`, `test/` or `pubspec.yaml`; all six remaining declared asset dirs exist
- [ ] 2.4 Manual (device): confirm a release build (`flutter build ipa --release`) launches without asset errors

## 3. Clean the repository root

- [x] 3.1 Remove `firebase-debug.log` — absent
- [x] 3.2 Remove `.DS_Store` — absent
- [x] 3.3 Confirm `*.log` and `.DS_Store` are covered by `.gitignore` — `git check-ignore`: `.gitignore:39` (`*.log`), `.gitignore:2` (`.DS_Store`)
- [x] 3.4 Confirm the fastlane artifact ignore rules from `secrets-hygiene` are in place — `.gitignore:35-36` match `ios/fastlane/README.md` and `report.xml`

## 4. Decide the review screenshots

- [x] 4.1 Determine what `brainy-app/screenshots/review_*.png` document — App Review evidence of the removed paywall (`review_paywall`, `review_onboarding_paywall`, `review_premium_lock`, `review_screenshot`)
- [x] 4.2 Either commit them with a note explaining their purpose, or add them to `.gitignore` — ignored with a purpose comment (`.gitignore:44-45`); kept locally
- [x] 4.3 Confirm nothing is left untracked without a decision — `git status --porcelain` empty

## 5. Verify and set the standard

- [x] 5.1 Confirm `git status --porcelain` is empty on a clean checkout — empty on `chore/finish-audit-changes`
- [x] 5.2 After `remove-monetization-go-free` lands, audit `lib/` for unreferenced Dart files — import-graph walk from `lib/main.dart`: 65/65 files reachable
- [x] 5.3 Wire up or delete anything that audit finds — nothing found at file level (orphans already removed in 1.1/1.4)
- [x] 5.4 Add an unreferenced-file check to the `/review` command checklist — `.claude/commands/review.md:30`, plus identifier (`:29`) and decorative-control (`:31`) checks
- [~] 5.5 Unused constants found during the audit — out of scope (this change's standard is file-level); reported for follow-up: `AppColors.backgroundGradient` (`app_colors.dart:23`), `AppConstants.ageOptions` (`app_constants.dart:117`), `AppConstants.goalOptions` (`app_constants.dart:118`; literals duplicated in `age_page.dart:16-18`, `goals_page.dart:17-20`)
