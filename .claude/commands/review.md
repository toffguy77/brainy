---
description: Use when the user wants a code review of current changes, before committing, or to validate changes against feature plans. Triggers on /review command.
---

# Code Review

Review current changes against feature plans and coding standards.

## Flow

1. **Read diff:** `git diff` (unstaged) + `git diff --cached` (staged)

2. **Find relevant plans:**
   - Extract keywords from changed file paths (e.g., `features/game/` → game, schulte, grid)
   - Grep tags in `docs/plans/features/*.md` frontmatter
   - Fallback: search plan content and filenames
   - Read all matched plans

3. **Review checklist:**
   - [ ] Code matches behavior described in plans
   - [ ] If behavior changed → plans are updated in the same diff
   - [ ] Tests cover new/changed behavior
   - [ ] Localization: new strings added to both `l10n/app_ru.arb` and `l10n/app_en.arb`
   - [ ] No magic strings (constants in `lib/constants/`)
   - [ ] No hardcoded text in UI
   - [ ] Riverpod for state (no setState in business logic)
   - [ ] Feature-first structure respected
   - [ ] No security issues (no secrets in code, no SQL injection, no XSS)
   - [ ] Every identifier, path, constant and key a touched plan names exists in code (grep each one)
   - [ ] No unreferenced Dart files in `lib/` — every new file is imported or routed; delete or wire up
   - [ ] Every new setting/control has a consumer that changes observable behaviour

4. **Output:**
   - If issues found: list each issue with file:line, what's wrong, and how to fix
   - If clean: approve with brief summary of what was reviewed

## Severity levels

- **Blocker:** Plan not updated, tests missing, security issue
- **Warning:** Style issue, could be improved
- **Note:** Suggestion, not required
