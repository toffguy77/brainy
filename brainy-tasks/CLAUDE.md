# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **task specification repository** (not source code) for **Brainy** — a Flutter mobile app for training attention and reading speed in children ages 6–14 using Schulte tables. All specs are written in Russian.

The actual Flutter project should be created separately following these specs.

## Repository Structure

- `MASTER_CONTEXT.md` — Master project context: tech stack, game mechanics, characters, monetization, design system, and code rules. **Must be referenced alongside every task file.**
- `TASK_X_Y_*.md` — Sequential implementation tasks organized in phases:
  - **Phase 1**: Project structure & navigation
  - **Phase 2**: Game logic, game screen, result screen
  - **Phase 3**: Onboarding, profile/streaks, coins/XP
  - **Phase 4**: Characters, accessories
  - **Phase 5**: Parent panel, RevenueCat, paywall
  - **Phase 6**: Sounds/notifications, App Store submission

## Tech Stack (for the target Flutter project)

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod |
| Local DB | Hive |
| Backend | Firebase (Auth, Firestore, Analytics, Crashlytics) |
| Subscriptions | RevenueCat |
| Animations | Lottie + Flutter animations |
| Localization | flutter_intl (ARB files, RU + EN) |
| Navigation | go_router |

## Key Architecture Rules (from MASTER_CONTEXT.md)

- **Feature-first architecture** — each feature isolated in its own folder under `lib/features/`
- **Riverpod for all state** — no setState in business logic
- **Hive for local data** — sessions, settings, cache
- **Firestore for cloud** — progress, accounts, leagues
- **Offline-first** — game works offline, syncs when connected
- **No magic strings** — all constants in dedicated files
- **All text localized** — no hardcoded strings, use `AppLocalizations.of(context)!`

## Design System

- Dark theme primary (game-like aesthetic)
- Brand color: `#6C5CE7` (purple), accent: `#00CEC9` (teal), rewards: `#FDCB6E` (yellow)
- Background: `#0D0D1A`, surfaces: `#1A1A2E`
- Font: Nunito throughout (Bold for grid numbers)
- Rounded corners (16–24 border radius)
- Animations on every action (150–300ms minimum)
- Haptic feedback on every game tap
