---
description: Use when the user wants to deploy a new build to TestFlight, bump version, or ship a build. Triggers on /deploy command.
---

# Deploy to TestFlight

Bump build number, push to main. GitHub Actions deploys to TestFlight automatically.

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

3. **Commit and push:**
   ```bash
   git add brainy-app/pubspec.yaml
   git commit -m "chore: bump build number to {new_build_number}"
   git push origin main
   ```

4. **Confirm:** Tell user the push was made and GitHub Actions will deploy to TestFlight.

## Full App Store Release

For a full release (TestFlight + metadata + App Store review), create a version tag instead:
```bash
git tag v{version}
git push origin v{version}
```
This triggers `release.yml` which builds, uploads to TestFlight, waits for processing, and submits for review.

**Do NOT push to main AND create a tag in the same operation** — this triggers both `deploy-testflight.yml` and `release.yml`, causing a double build.

## Notes

- If tests or analyze fail, fix issues first. Do not deploy broken code.
- If the branch is not main, ask user if they want to proceed anyway.
