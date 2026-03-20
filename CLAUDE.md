## Plans

- `docs/plans/features/` — living documentation of app behavior (source of truth)
- Before implementation — read relevant plans (grep tags in YAML frontmatter)
- After implementation — update affected plans in the same commit
- Format: YAML frontmatter with `title` and `tags` fields
- Plan search: grep tags first, fallback to content/filename search, warn if zero results

## Skills

- `/feature` — full feature cycle: questions → plan → checkpoint → implement → test → build → checkpoint → commit → PR
- `/deploy` — bump build number + tag for TestFlight deployment
- `/appstore` — App Store metadata, screenshots, submission
- `/review` — code review against feature plans and coding standards

## Architecture Rules

- Feature-first: each feature in `lib/features/<name>/`
- Riverpod for all state (no setState in business logic)
- Hive for local data, Firestore for cloud
- All text localized via ARB files (`l10n/app_ru.arb`, `l10n/app_en.arb`)
- No magic strings — use `lib/constants/`
- Dark theme, brand purple #6C5CE7, animations on actions, haptic on taps
