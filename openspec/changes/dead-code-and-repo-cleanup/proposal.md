## Why

Dead code and repository noise are individually trivial and collectively corrosive: they make a `git status` unreadable, make grep results untrustworthy, and make it harder to tell whether something is unused or merely unreferenced-so-far. Several small instances have accumulated.

`ParentScreen` is never imported and has no route, yet it holds the only hardcoded Russian string in `lib/` — `Text('Родитель')` — silently violating the project's "all text localized" rule while being invisible to anyone reading the running app. `assets/animations/` is declared in `pubspec.yaml` and is empty. A 1.3 MB `firebase-debug.log` and a `.DS_Store` sat in the repository root. Untracked fastlane artifacts and review screenshots clutter every status check.

## What Changes

- `ParentScreen` is deleted, taking the last hardcoded UI string with it.
- The empty `assets/animations/` declaration is removed from `pubspec.yaml`, or the directory is populated if animations are actually planned.
- Stray root files (`firebase-debug.log`, `.DS_Store`) are removed.
- Untracked fastlane artifacts are ignored (handled in `secrets-hygiene`).
- The four `brainy-app/screenshots/review_*.png` files are either committed with a stated purpose or ignored.
- A rule is established: any Dart file in `lib/` that nothing imports is either wired up or deleted.

## Capabilities

### New Capabilities
- `repository-hygiene`: what may exist in the tree, and the standard for unreferenced code.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for repository structure. -->

## Impact

- `brainy-app/lib/features/parent/screens/parent_screen.dart` — deleted.
- `brainy-app/pubspec.yaml` — the `assets/animations/` line.
- Repository root — `firebase-debug.log`, `.DS_Store` removed.
- `.gitignore` — fastlane artifacts (in `secrets-hygiene`), possibly review screenshots.
- `git status` becomes a meaningful signal again.

Note: `remove-monetization-go-free` deletes far more code than this change does. This one covers what is dead for no reason, rather than dead by decision.
