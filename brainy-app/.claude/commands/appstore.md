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
