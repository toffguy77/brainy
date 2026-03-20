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
