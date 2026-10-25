## Context

The audit found several small hygiene defects, none individually urgent:

- `parent_screen.dart` defines `ParentScreen`, which nothing imports and no route registers. The parent feature is served by `parent_pin_screen`, `parent_dashboard_screen` and `parent_settings_screen`; this is a leftover from an earlier structure. It contains `Text('Родитель')` — the only hardcoded user-facing string in `lib/`, and invisible precisely because the widget never renders.
- `pubspec.yaml` declares `assets/animations/`, which is empty.
- `firebase-debug.log` (1.3 MB) and `.DS_Store` sat in the repository root, untracked but present.
- Fastlane regenerates `README.md` and `report.xml` on every run, both untracked.
- Four `review_*.png` screenshots sit untracked in `brainy-app/screenshots/`.

The connecting thread is signal degradation. When `git status` always shows seven irrelevant entries, nobody reads it, and a genuinely unexpected file goes unnoticed. The dead `ParentScreen` shows the same effect in code: a rule violation survived because it lived somewhere nobody looks.

## Goals / Non-Goals

**Goals:**
- Delete what is dead.
- Make `git status` empty on a clean checkout.
- Remove the last hardcoded string.

**Non-Goals:**
- A full dead-code sweep with tooling. `remove-monetization-go-free` removes a large surface; a systematic pass makes more sense after it lands, against a smaller tree.
- Restructuring the parent feature. Only the orphan is removed.
- Deciding whether animations belong in the product. Only the empty declaration is resolved.

## Decisions

**Delete `ParentScreen` rather than wire it in.** Three parent screens already cover the surface, and there is no gap it fills. Deleting it also removes the hardcoded string, which is the more valuable half of the outcome.

*Alternative considered:* keep it and localize the string. Rejected — localizing a widget nobody renders is work that produces nothing.

**Remove the `assets/animations/` declaration rather than add placeholder assets.** Declaring an empty directory is a statement of intent with no follow-through; if animations are added later, the declaration comes back with them.

**Decide the review screenshots explicitly.** They appear to be evidence captured for an App Store review response. If that is right, they belong tracked with a note explaining what they document, since the app has already had a 2.3.8 rejection and evidence for the next round has value. If they were throwaway, ignore them. Leaving them untracked is the only wrong answer.

**Do not add a lint that fails on unreferenced files.** Dart has no reliable built-in for this and third-party tooling produces false positives on generated and platform-entry code. The requirement is stated as a standard for review rather than an automated check, which is honest about what is enforceable.

**Sequence after `remove-monetization-go-free`.** Auditing for unreferenced files before that change lands would mean auditing a tree about to lose an entire feature directory.

## Risks / Trade-offs

- **Deleting a file that turns out to be needed** → The compiler and CI catch it immediately; `ParentScreen` has no importers, so the risk is essentially nil.
- **Ignoring the review screenshots loses evidence for a future App Store dispute** → The reason the decision is made explicitly rather than defaulting to ignore.
- **The "no unreferenced files" rule is unenforceable and will decay** → Accepted and stated plainly. A rule applied at review time is worth more than a false claim of automation.
- **Removing the asset declaration breaks a build referencing an animation** → Nothing references it; the directory is empty.

## Migration Plan

1. Delete `parent_screen.dart`; confirm `flutter analyze` stays clean.
2. Remove the `assets/animations/` line from `pubspec.yaml`; confirm the app builds.
3. Remove `firebase-debug.log` and `.DS_Store`.
4. Confirm the fastlane ignore rules from `secrets-hygiene` are in place.
5. Decide the fate of the review screenshots and act on it.
6. Verify `git status --porcelain` is empty on a clean checkout.
7. After `remove-monetization-go-free`, audit the remaining tree for unreferenced files.

**Rollback:** every deletion is an ordinary revert.

## Open Questions

- What do `review_*.png` document, and is that worth keeping?
- Were animations ever planned, or is the directory a leftover from scaffolding?
- Is a periodic unreferenced-file audit worth adding to the `/review` command's checklist?
