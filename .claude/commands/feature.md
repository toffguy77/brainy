---
description: Use when the user wants to implement a new feature, change behavior, or fix a bug in the Brainy app. Triggers on /feature command or when user describes a feature request.
---

# Feature Development

Full feature development cycle with two checkpoints.

## Flow

### Phase 1: Understanding (before code)

1. **Find relevant plans** — grep tags in `docs/plans/features/*.md` YAML frontmatter for keywords related to the task. Fallback: search file content and filenames. If zero results, warn user and ask whether to proceed.
2. **Read matched plans** — understand current app behavior in affected areas.
3. **Ask clarifying questions** — one question at a time until the task is clear.
4. **Present plan** — show: what code changes, what tests, what plans will be updated.

**CHECKPOINT 1:** Wait for user approval before writing any code.

### Phase 2: Implementation (autonomous)

5. **Write code** — implementation + tests + localization (l10n/*.arb).
6. **Update plans** — modify affected files in `docs/plans/features/` to reflect new behavior. If behavior described in ANY existing plan changes, that plan MUST be updated.
7. **Verify locally:**
   - `cd brainy-app && flutter test`
   - `cd brainy-app && flutter analyze`
   - `cd brainy-app && flutter build ios --no-codesign`
8. **If verification fails** — fix and re-run. Do not present to user until all green.

**CHECKPOINT 2:** Show test results, build output, and `git diff`. Wait for explicit "ok" from user.

### Phase 3: Ship (after approval)

9. **Commit** — code + updated plans in one commit.
10. **Push** — to feature branch.
11. **Create PR** — against main with summary of changes.

## Rules

- Plans in `docs/plans/features/` are source of truth. Always read before, always update after.
- All text must be localized (no hardcoded strings). Update both `l10n/app_ru.arb` and `l10n/app_en.arb`.
- Use Riverpod for state. No setState in business logic.
- Use constants from `lib/constants/`. No magic strings.
- Follow feature-first architecture: `lib/features/<feature>/`.
- Dark theme, brand purple #6C5CE7, rounded corners, animations on actions, haptic on taps.
