# Agent System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a two-layer agent system (CLI skills + GitHub Actions) for quality, autonomy, and operations automation in the Brainy app.

**Architecture:** Claude Code custom skills (`/feature`, `/deploy`, `/appstore`, `/review`) handle local development with checkpoints. GitHub Actions workflows handle remote operations (TestFlight deploy, App Store release, daily monitoring). `docs/plans/features/` serves as living documentation of app behavior.

**Tech Stack:** Claude Code Skills (SKILL.md), GitHub Actions, Fastlane, App Store Connect API, Flutter

**Spec:** `docs/specs/2026-03-20-agent-system-design.md`

---

## Chunk 1: Feature Plans (Living Documentation)

### Task 1: Create docs/plans/ directory structure

**Files:**
- Create: `docs/plans/features/game-modes.md`
- Create: `docs/plans/features/character-system.md`
- Create: `docs/plans/features/progress-tracking.md`
- Create: `docs/plans/features/parent-panel.md`
- Create: `docs/plans/features/subscription.md`
- Create: `docs/plans/features/leaderboards.md`
- Create: `docs/plans/features/notifications.md`
- Create: `docs/plans/features/localization.md`
- Create: `docs/plans/features/onboarding.md`
- Create: `docs/plans/ops/ci-cd.md`
- Create: `docs/plans/ops/appstore-metadata.md`

Each plan must:
- Start with YAML frontmatter (`title`, `tags`)
- Describe current behavior (not desired behavior)
- Be generated from three sources: `brainy-tasks/MASTER_CONTEXT.md` + `TASK_*.md`, `~/.claude/plans/*.md`, and actual code in `brainy-app/lib/`

- [ ] **Step 1: Read all source materials**

Read and extract relevant information from:
- `brainy-tasks/MASTER_CONTEXT.md` — overall context
- `brainy-tasks/TASK_2_1_game_logic.md`, `TASK_2_2_game_screen.md`, `TASK_2_3_result_screen.md` — game mechanics
- `brainy-tasks/TASK_4_1_characters.md`, `TASK_4_2_accessories.md` — character system
- `brainy-tasks/TASK_3_2_profile_streak.md`, `TASK_3_3_coins_xp.md`, `TASK_3_4_grid_detail_charts.md` — progress
- `brainy-tasks/TASK_5_1_parent_panel.md` — parent panel
- `brainy-tasks/TASK_5_2_revenuecat.md`, `TASK_5_3_paywall.md`, `TASK_10_1_yookassa.md` — subscription
- `brainy-tasks/TASK_8_1_game_center_leaderboards.md` — leaderboards
- `brainy-tasks/TASK_6_1_notifications.md` — notifications
- `brainy-tasks/TASK_3_1_onboarding.md`, `TASK_3_1a_onboarding_info_screens.md` — onboarding
- `brainy-tasks/TASK_6_2_appstore.md`, `TASK_7_7_appstore_metadata.md`, `TASK_7_9_screenshots.md` — App Store
- `brainy-tasks/TASK_9_1_premium_audit_fixes.md` — premium audit (Gorbov mode, 9x9)
- `~/.claude/plans/*.md` — scan all files, extract Brainy-relevant content
- Verify against actual code in `brainy-app/lib/` to ensure plans reflect reality

- [ ] **Step 2: Create `docs/plans/features/game-modes.md`**

```markdown
---
title: Игровые режимы
tags: [game, schulte, gorbov, grid, classic, modes, session, records, timer]
---

# Игровые режимы

[Content generated from sources — describes actual current behavior:
- Classic mode: ascending 1→N²
- Gorbov mode: alternating white ascending + red descending (Premium)
- Grid sizes: 3x3-7x7 + 9x9, premium gates on 6x6+
- Timer mechanics, error penalties (+2 sec)
- Records tracking per mode per grid size (classic_N / gorbov_N keys)
- Adaptive difficulty thresholds
- Session model and Hive persistence]
```

- [ ] **Step 3: Create `docs/plans/features/character-system.md`**

```markdown
---
title: Система персонажей
tags: [character, accessories, coins, cosmetics, shop, pixel, brainy, zap, vortex, glitch]
---
```

Content: 5 characters, unlock conditions, accessories (hat/glasses/cape/effect), coin pricing, premium-exclusive Pixel character.

- [ ] **Step 4: Create `docs/plans/features/progress-tracking.md`**

```markdown
---
title: Прогресс и геймификация
tags: [progress, xp, streaks, achievements, stats, coins, level, charts]
---
```

Content: XP formula (cells = XP), levels, coin rewards, streak mechanics, achievements list, grid stats with fl_chart, 7-day vs all-time stats (premium).

- [ ] **Step 5: Create `docs/plans/features/parent-panel.md`**

```markdown
---
title: Панель родителя
tags: [parent, pin, dashboard, settings, share, premium]
---
```

Content: PIN access (4-digit), dashboard (premium-gated), settings (notifications, app info), share card generation, navigation flow.

- [ ] **Step 6: Create `docs/plans/features/subscription.md`**

```markdown
---
title: Подписка и Premium
tags: [premium, paywall, yookassa, payment, subscription, free, locked]
---
```

Content: Premium features list, YooKassa payment flow (device ID → token → Cloud Function → Firestore), pricing (299₽/mo, 1990₽/yr), Hive caching, what's gated (Gorbov, 6x6+, parent dashboard, Pixel character). Note: RevenueCat removed, YooKassa backend deployed but not yet live in production.

- [ ] **Step 7: Create `docs/plans/features/leaderboards.md`**

```markdown
---
title: Лидерборды и Game Center
tags: [gamecenter, leaderboard, league, ranking, weekly, besttime]
---
```

Content: 7 leaderboards (weekly_xp recurring + 6 best_time classic), Game Center integration via games_services, score submission on session end.

- [ ] **Step 8: Create `docs/plans/features/notifications.md`**

```markdown
---
title: Уведомления
tags: [notifications, reminders, schedule, permissions]
---
```

Content: Daily reminders (configurable time), streak notifications, flutter_local_notifications v21 API, permission_handler flow.

- [ ] **Step 9: Create `docs/plans/features/localization.md`**

```markdown
---
title: Локализация
tags: [l10n, i18n, russian, english, arb, intl]
---
```

Content: RU (primary) + EN, ARB files in `l10n/`, code generation via build_runner, AppLocalizations usage pattern, what's localized (UI, achievements, metadata).

- [ ] **Step 10: Create `docs/plans/features/onboarding.md`**

```markdown
---
title: Онбординг
tags: [onboarding, tutorial, firstlaunch, welcome, age, goals]
---
```

Content: 5-screen flow (welcome → age → goal → frequency → paywall), Hive flag for completion, navigation to home after.

- [ ] **Step 11: Create `docs/plans/ops/ci-cd.md`**

```markdown
---
title: CI/CD Pipeline
tags: [ci, cd, github-actions, testflight, fastlane, deploy, certificate]
---
```

Content: Current deploy-ios.yml (tag-triggered), submit-review.yml (manual), Fastfile lanes, secrets list, signing process.

- [ ] **Step 12: Create `docs/plans/ops/appstore-metadata.md`**

```markdown
---
title: App Store Metadata
tags: [appstore, metadata, screenshots, keywords, description, review]
---
```

Content: Fastlane metadata structure (en-US + ru), screenshot sizes (6.7", 6.5", iPad 13"), compose_screenshots.py, review notes, privacy/support URLs.

- [ ] **Step 13: Archive brainy-tasks/**

Create `brainy-tasks/README.md` marking it as archived:

```markdown
# ⚠️ Archived

This directory contains the original task specifications used to build Brainy.

**For current feature documentation, see `docs/plans/features/`.**

These files are kept for historical reference only and are no longer maintained.
```

- [ ] **Step 14: Commit all plans and archive notice**

```bash
cd /Users/thatguy/src/brainy
git add docs/plans/ brainy-tasks/README.md
git commit -m "docs: add living feature plans as source of truth, archive brainy-tasks"
```

---

## Chunk 2: CLI Skills

### Task 2: Create `/feature` skill

**Files:**
- Create: `brainy-app/.claude/commands/feature.md`

The skill defines the full feature development cycle with two checkpoints.

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p /Users/thatguy/src/brainy/brainy-app/.claude/commands
```

- [ ] **Step 2: Write command file**

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add brainy-app/.claude/commands/feature.md
git commit -m "feat: add /feature skill for full feature development cycle"
```

### Task 3: Create `/deploy` skill

**Files:**
- Create: `brainy-app/.claude/commands/deploy.md`

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p /Users/thatguy/src/brainy/brainy-app/.claude/commands
```

- [ ] **Step 2: Write command file**

```markdown
---

description: Use when the user wants to deploy a new build to TestFlight, bump version, create a release tag, or ship a build. Triggers on /deploy command.
---

# Deploy to TestFlight

Bump build number, tag, push. GitHub Actions handles the rest.

## Flow

1. **Check prerequisites:**
   - Current branch is `main` (warn if not)
   - Working tree is clean (`git status` shows no changes)
   - Tests pass: `cd brainy-app && flutter test`
   - Analyze passes: `cd brainy-app && flutter analyze`

2. **Bump build number** in `brainy-app/pubspec.yaml`:
   - Parse current version (e.g., `1.1.0+15`)
   - Increment only the build number after `+` (e.g., `1.1.0+16`)
   - Do NOT change the version string — that is set manually by the developer

3. **Commit:**
   ```bash
   git add brainy-app/pubspec.yaml
   git commit -m "chore: bump build number to {new_build_number}"
   ```

4. **Tag and push:**
   ```bash
   git tag v{version}+{new_build_number}
   git push origin main --tags
   ```

5. **Confirm:** Tell user the tag was pushed and GitHub Actions will deploy to TestFlight.

## Notes

- If tests or analyze fail, fix issues first. Do not deploy broken code.
- If the branch is not main, ask user if they want to proceed anyway (TestFlight builds from any branch, but release workflow only triggers on main).
```

- [ ] **Step 3: Commit**

```bash
git add brainy-app/.claude/commands/deploy.md
git commit -m "feat: add /deploy skill for TestFlight deployment"
```

### Task 4: Create `/appstore` skill

**Files:**
- Create: `brainy-app/.claude/commands/appstore.md`

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p /Users/thatguy/src/brainy/brainy-app/.claude/commands
```

- [ ] **Step 2: Write command file**

```markdown
---

description: Use when the user wants to update App Store metadata, screenshots, submit for review, or manage App Store Connect. Triggers on /appstore command.
---

# App Store Operations

Update metadata, screenshots, and submit for App Store review.

## Flow

1. **Ask what to do:**
   - Update metadata (descriptions, keywords, release notes)
   - Update screenshots
   - Submit for review
   - Check review status

2. **For metadata updates:**
   - Edit files in `brainy-app/ios/fastlane/metadata/en-US/` and `brainy-app/ios/fastlane/metadata/ru/`
   - Available files: name.txt, subtitle.txt, description.txt, keywords.txt (max 100 chars), promotional_text.txt, release_notes.txt
   - Commit changes

3. **For screenshot updates:**
   - Generate screenshots using `brainy-app/scripts/compose_screenshots.py`
   - Copy to `brainy-app/ios/fastlane/screenshots/` in correct device/locale structure
   - Sizes: 6.7" (1290x2796), 6.5" (1242x2688), iPad 13" (2048x2732)

4. **For submission:**
   - Run: `cd brainy-app/ios && bundle exec fastlane submit_review`
   - Requires env vars: APP_STORE_CONNECT_API_KEY, APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID
   - If Fastlane fails, check error and suggest fixes

5. **Game Center check:**
   - After submission, check Game Center leaderboard status via App Store Connect API
   - If leaderboards are in DEVELOPER_REJECTED status, remind user to resubmit them manually in App Store Connect
   - Game Center submissions cannot be fully automated via API

6. **For status check:**
   - Use App Store Connect API with JWT auth
   - API key at: `~/Downloads/AuthKey_Q2Q32CN7T9.p8`
   - Key ID: `Q2Q32CN7T9`, Issuer ID: `e5ce9346-27fe-433e-8fbc-a88e6f02ef1a`
   - App ID: `6760589477`

## Metadata constraints

- App name: max 30 characters
- Subtitle: max 30 characters
- Keywords: max 100 characters (comma-separated, Apple counts Unicode chars not bytes)
- Description: max 4000 characters
- Release notes: max 4000 characters
```

- [ ] **Step 3: Commit**

```bash
git add brainy-app/.claude/commands/appstore.md
git commit -m "feat: add /appstore skill for App Store operations"
```

### Task 5: Create `/review` skill

**Files:**
- Create: `brainy-app/.claude/commands/review.md`

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p /Users/thatguy/src/brainy/brainy-app/.claude/commands
```

- [ ] **Step 2: Write command file**

```markdown
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

4. **Output:**
   - If issues found: list each issue with file:line, what's wrong, and how to fix
   - If clean: approve with brief summary of what was reviewed

## Severity levels

- **Blocker:** Plan not updated, tests missing, security issue
- **Warning:** Style issue, could be improved
- **Note:** Suggestion, not required
```

- [ ] **Step 3: Commit**

```bash
git add brainy-app/.claude/commands/review.md
git commit -m "feat: add /review skill for code review against feature plans"
```

---

## Chunk 3: GitHub Actions Workflows

### Task 6: Create `release.yml` workflow

This MUST be created and verified BEFORE modifying `deploy-ios.yml`. Migration order from spec.

**Files:**
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Write release.yml**

```yaml
name: Release to App Store

on:
  push:
    tags:
      - 'v*'

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

jobs:
  release:
    runs-on: macos-15
    timeout-minutes: 60
    defaults:
      run:
        working-directory: brainy-app

    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Select Xcode 26
        run: sudo xcode-select -s /Applications/Xcode_26.3.app/Contents/Developer

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: brainy-app/ios

      - name: Install CocoaPods and run pod install
        run: |
          gem install cocoapods
          cd ios
          pod install

      - name: Decode distribution certificate
        env:
          DISTRIBUTION_CERTIFICATE_P12: ${{ secrets.DISTRIBUTION_CERTIFICATE_P12 }}
        run: echo "$DISTRIBUTION_CERTIFICATE_P12" | base64 --decode > ios/fastlane/certificate.p12

      - name: Decode provisioning profile
        env:
          PROVISIONING_PROFILE: ${{ secrets.PROVISIONING_PROFILE }}
        run: echo "$PROVISIONING_PROFILE" | base64 --decode > ios/fastlane/profile.mobileprovision

      - name: Build, sign, upload to TestFlight and submit for review
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          APP_STORE_CONNECT_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          DISTRIBUTION_CERTIFICATE_PASSWORD: ${{ secrets.DISTRIBUTION_CERTIFICATE_PASSWORD }}
          REVENUECAT_API_KEY: ${{ secrets.REVENUECAT_API_KEY }}
        run: |
          cd ios
          bundle exec fastlane release

      - name: Clean up secrets
        if: always()
        run: |
          rm -f ios/fastlane/certificate.p12
          rm -f ios/fastlane/profile.mobileprovision
```

- [ ] **Step 2: Add `release` lane to Fastfile**

Add to `brainy-app/ios/fastlane/Fastfile` after the `submit_review` lane:

```ruby
  desc "Full release: build, upload to TestFlight, wait for processing, deliver metadata, submit for review"
  lane :release do
    setup_ci

    api_key = app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_ISSUER_ID"],
      key_content: ENV["APP_STORE_CONNECT_API_KEY"],
      is_key_content_base64: true,
    )

    import_certificate(
      certificate_path: "fastlane/certificate.p12",
      certificate_password: ENV["DISTRIBUTION_CERTIFICATE_PASSWORD"],
      keychain_name: "fastlane_tmp_keychain",
      keychain_password: "",
    )

    profile_path = install_provisioning_profile(path: "fastlane/profile.mobileprovision")
    profile_uuid = File.basename(profile_path, ".mobileprovision")

    update_code_signing_settings(
      use_automatic_signing: false,
      path: "Runner.xcodeproj",
      team_id: "3GWRDGA8B7",
      code_sign_identity: "Apple Distribution",
      profile_uuid: profile_uuid,
      bundle_identifier: "com.brainyapp.brainy",
    )

    Dir.chdir("../..") do
      sh("flutter", "build", "ios",
        "--release",
        "--no-codesign",
        "--dart-define=REVENUECAT_API_KEY=#{ENV['REVENUECAT_API_KEY']}",
      )
    end

    installed_profile = File.join(
      Dir.home, "Library/Developer/Xcode/UserData/Provisioning Profiles",
      "#{profile_uuid}.mobileprovision"
    )
    profile_plist = sh("security", "cms", "-D", "-i", installed_profile, log: false)
    profile_name = profile_plist.match(/<key>Name<\/key>\s*<string>(.*?)<\/string>/m)[1]

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          "com.brainyapp.brainy" => profile_name,
        },
      },
      output_directory: "../../build/ios/ipa",
      output_name: "brainy.ipa",
    )

    upload_to_testflight(
      api_key: api_key,
      ipa: "../../build/ios/ipa/brainy.ipa",
      skip_waiting_for_build_processing: false,
      wait_for_uploaded_build: true,
      distribute_external: false,
      changelog: ENV["CHANGELOG"] || "New build",
    )

    deliver(
      api_key: api_key,
      app_identifier: "com.brainyapp.brainy",
      submit_for_review: true,
      automatic_release: true,
      force: true,
      skip_binary_upload: true,
      overwrite_screenshots: true,
      precheck_include_in_app_purchases: false,
      submission_information: {
        add_id_info_uses_idfa: false,
      },
    )
  end
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/release.yml brainy-app/ios/fastlane/Fastfile
git commit -m "feat: add release workflow for full App Store release pipeline"
```

### Task 7: Verify `release.yml` works before migration

- [ ] **Step 1: Push release.yml and test with a dry-run tag**

```bash
git push origin HEAD
# Create a test tag to verify release.yml triggers correctly
git tag v0.0.0-test
git push origin v0.0.0-test
```

- [ ] **Step 2: Verify in GitHub Actions**

Go to GitHub Actions and confirm `Release to App Store` workflow triggered. It will fail at the build step (expected — not a real version), but the workflow YAML must parse and trigger correctly.

- [ ] **Step 3: Clean up test tag**

```bash
git tag -d v0.0.0-test
git push origin --delete v0.0.0-test
```

Only proceed to Task 8 after confirming release.yml triggers correctly.

### Task 8: Create `deploy-testflight.yml` and remove old `deploy-ios.yml`

**Files:**
- Create: `.github/workflows/deploy-testflight.yml`
- Delete: `.github/workflows/deploy-ios.yml`

- [ ] **Step 1: Write deploy-testflight.yml**

Copy the current `deploy-ios.yml` but change the trigger from `tags: [v*]` to `branches: [main]`:

```yaml
name: Deploy to TestFlight

on:
  push:
    branches:
      - main

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

jobs:
  deploy:
    runs-on: macos-15
    timeout-minutes: 30
    defaults:
      run:
        working-directory: brainy-app

    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Select Xcode 26
        run: sudo xcode-select -s /Applications/Xcode_26.3.app/Contents/Developer

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: brainy-app/ios

      - name: Install CocoaPods and run pod install
        run: |
          gem install cocoapods
          cd ios
          pod install

      - name: Decode distribution certificate
        env:
          DISTRIBUTION_CERTIFICATE_P12: ${{ secrets.DISTRIBUTION_CERTIFICATE_P12 }}
        run: echo "$DISTRIBUTION_CERTIFICATE_P12" | base64 --decode > ios/fastlane/certificate.p12

      - name: Decode provisioning profile
        env:
          PROVISIONING_PROFILE: ${{ secrets.PROVISIONING_PROFILE }}
        run: echo "$PROVISIONING_PROFILE" | base64 --decode > ios/fastlane/profile.mobileprovision

      - name: Deploy to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          APP_STORE_CONNECT_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          DISTRIBUTION_CERTIFICATE_PASSWORD: ${{ secrets.DISTRIBUTION_CERTIFICATE_PASSWORD }}
          REVENUECAT_API_KEY: ${{ secrets.REVENUECAT_API_KEY }}
        run: |
          cd ios
          bundle exec fastlane deploy_testflight

      - name: Clean up secrets
        if: always()
        run: |
          rm -f ios/fastlane/certificate.p12
          rm -f ios/fastlane/profile.mobileprovision
```

- [ ] **Step 2: Delete old deploy-ios.yml**

```bash
git rm .github/workflows/deploy-ios.yml
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy-testflight.yml
git commit -m "feat: migrate deploy workflow from tag-triggered to push-to-main"
```

### Task 9: Create `monitor.yml` workflow

**Files:**
- Create: `.github/workflows/monitor.yml`

- [ ] **Step 1: Write monitor.yml**

```yaml
name: Monitor App Store Review Status

on:
  schedule:
    - cron: '0 9 * * *'  # Daily at 9:00 UTC (12:00 MSK)
  workflow_dispatch:       # Allow manual trigger

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

jobs:
  check-review-status:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: Check App Store review status
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          APP_STORE_CONNECT_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_ID: '6760589477'
        run: |
          # Install dependencies
          pip install PyJWT requests cryptography

          python3 << 'PYTHON_SCRIPT'
          import jwt, time, requests, json, os

          KEY_ID = os.environ["APP_STORE_CONNECT_KEY_ID"]
          ISSUER_ID = os.environ["APP_STORE_CONNECT_ISSUER_ID"]
          API_KEY = os.environ["APP_STORE_CONNECT_API_KEY"]
          APP_ID = os.environ["APP_ID"]

          # Decode base64 key
          import base64
          private_key = base64.b64decode(API_KEY).decode("utf-8")

          # Generate JWT
          now = int(time.time())
          token = jwt.encode(
              {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
              private_key, algorithm="ES256",
              headers={"kid": KEY_ID, "typ": "JWT"}
          )

          H = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
          BASE = "https://api.appstoreconnect.apple.com/v1"

          # Get latest app store version
          r = requests.get(f"{BASE}/apps/{APP_ID}/appStoreVersions?limit=1&sort=-createdDate", headers=H)
          r.raise_for_status()
          versions = r.json()["data"]

          if not versions:
              print("No app store versions found")
              exit(0)

          v = versions[0]
          state = v["attributes"]["appVersionState"]
          version = v["attributes"]["versionString"]

          # States that need attention
          ALERT_STATES = ["REJECTED", "METADATA_REJECTED", "DEVELOPER_REJECTED", "READY_FOR_SALE"]

          print(f"Version {version}: {state}")

          if state in ALERT_STATES:
              # Write to GITHUB_OUTPUT for issue creation
              with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                  f.write(f"should_create_issue=true\n")
                  f.write(f"version={version}\n")
                  f.write(f"state={state}\n")
          else:
              with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                  f.write(f"should_create_issue=false\n")
          PYTHON_SCRIPT
        id: check

      - name: Create issue if status needs attention
        if: steps.check.outputs.should_create_issue == 'true'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Check if issue already exists for this version+state
          EXISTING=$(gh issue list --repo ${{ github.repository }} --label "app-store" --search "v${{ steps.check.outputs.version }} ${{ steps.check.outputs.state }}" --json number --jq length)
          if [ "$EXISTING" = "0" ]; then
            gh issue create \
              --repo ${{ github.repository }} \
              --title "App Store: v${{ steps.check.outputs.version }} — ${{ steps.check.outputs.state }}" \
              --body "Version **${{ steps.check.outputs.version }}** status changed to **${{ steps.check.outputs.state }}**. Check App Store Connect for details." \
              --label "app-store"
          fi
```

- [ ] **Step 2: Create the `app-store` label**

```bash
cd /Users/thatguy/src/brainy
gh label create "app-store" --description "App Store Connect status updates" --color "0075ca" 2>/dev/null || true
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/monitor.yml
git commit -m "feat: add daily App Store review status monitor workflow"
```

---

## Chunk 4: CLAUDE.md and Final Integration

### Task 10: Update CLAUDE.md

**Files:**
- Create or modify: `CLAUDE.md` (repo root)

- [ ] **Step 1: Check if CLAUDE.md exists at repo root**

```bash
ls /Users/thatguy/src/brainy/CLAUDE.md
```

- [ ] **Step 2: Create or update CLAUDE.md**

Add the following sections (append if file exists, create if not):

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add CLAUDE.md with plans, skills, and architecture rules"
```

### Task 11: Verify the system works end-to-end

- [ ] **Step 1: Test plan search**

```bash
cd /Users/thatguy/src/brainy
grep -rl "game" docs/plans/features/ --include="*.md"
```

Expected: at least `game-modes.md` and `leaderboards.md` appear.

- [ ] **Step 2: Test skill loading**

Start a new Claude Code session in the brainy-app directory and verify `/feature`, `/deploy`, `/appstore`, `/review` appear as available skills.

- [ ] **Step 3: Test `/review` on current diff**

Run `/review` on the current unstaged changes to verify it reads plans and produces review output.

- [ ] **Step 4: Verify GitHub Actions syntax**

```bash
cd /Users/thatguy/src/brainy
# Check YAML validity
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml')); print('release.yml: OK')"
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy-testflight.yml')); print('deploy-testflight.yml: OK')"
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/monitor.yml')); print('monitor.yml: OK')"
```

- [ ] **Step 5: Final commit with all remaining changes**

```bash
git status
# If any unstaged changes remain, stage and commit
```
