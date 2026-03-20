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

5. **Write code** — implementation + localization (l10n/*.arb).
6. **E2E тесты** — не просто генерировать тесты, а думать:
   - Прочитать существующие тесты в затронутых модулях (`test/`, `integration_test/`).
   - Если существующие тесты ломаются — разобраться: это баг в новом коде или тест устарел? Если баг — чинить код, не тест. Если тест устарел — обновить тест с пониманием нового поведения.
   - Писать новые тесты на добавленное поведение: проверять реальные сценарии (happy path + edge cases), а не формально покрывать строки.
   - Тесты должны быть стабильными (не flaky), учитывать scroll, animations, async providers.
7. **Update plans** — modify affected files in `docs/plans/features/` to reflect new behavior. If behavior described in ANY existing plan changes, that plan MUST be updated.
8. **Verify locally:**
   - `cd brainy-app && flutter test`
   - `cd brainy-app && flutter analyze`
   - `cd brainy-app && flutter build ios --no-codesign`
9. **If verification fails** — разобраться в причине. Не чинить тесты вслепую — если тест падает, это может быть баг в коде. Не представлять результат пользователю, пока всё не зелёное.

**CHECKPOINT 2:** Show test results, build output, and `git diff`. Wait for explicit "ok" from user.

### Phase 3: Ship (after approval)

10. **Commit** — code + updated plans + tests in one commit.
11. **Push** — to feature branch.
12. **Create PR** — against main with summary of changes.

## Rules

- Plans in `docs/plans/features/` are source of truth. Always read before, always update after.
- All text must be localized (no hardcoded strings). Update both `l10n/app_ru.arb` and `l10n/app_en.arb`.
- Use Riverpod for state. No setState in business logic.
- Use constants from `lib/constants/`. No magic strings.
- Follow feature-first architecture: `lib/features/<feature>/`.
- Dark theme, brand purple #6C5CE7, rounded corners, animations on actions, haptic on taps.
