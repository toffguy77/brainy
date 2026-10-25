## 1. Remove dead code

- [x] 1.1 Delete `brainy-app/lib/features/parent/screens/parent_screen.dart`
- [x] 1.2 Confirm nothing imported it and `flutter analyze` stays clean
- [x] 1.3 Confirm no hardcoded `Text('...')` with linguistic content remains in `lib/`

## 2. Resolve the empty asset declaration

- [ ] 2.1 Determine whether animations were planned or the directory is scaffolding residue
- [ ] 2.2 Remove `assets/animations/` from `pubspec.yaml`, or populate the directory
- [ ] 2.3 Confirm the app builds and no asset lookup fails

## 3. Clean the repository root

- [x] 3.1 Remove `firebase-debug.log`
- [x] 3.2 Remove `.DS_Store`
- [x] 3.3 Confirm `*.log` and `.DS_Store` are covered by `.gitignore`
- [x] 3.4 Confirm the fastlane artifact ignore rules from `secrets-hygiene` are in place

## 4. Decide the review screenshots

- [ ] 4.1 Determine what `brainy-app/screenshots/review_*.png` document
- [ ] 4.2 Either commit them with a note explaining their purpose, or add them to `.gitignore`
- [ ] 4.3 Confirm nothing is left untracked without a decision

## 5. Verify and set the standard

- [ ] 5.1 Confirm `git status --porcelain` is empty on a clean checkout
- [ ] 5.2 After `remove-monetization-go-free` lands, audit `lib/` for unreferenced Dart files
- [ ] 5.3 Wire up or delete anything that audit finds
- [ ] 5.4 Consider adding an unreferenced-file check to the `/review` command checklist
