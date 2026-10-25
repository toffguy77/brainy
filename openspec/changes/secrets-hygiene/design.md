## Context

Two independent exposures were found during the 2026-08-01 audit.

**Tracked credential.** `brainy-app/docs/setup/revenue_cat/credentials.md` contains `API_KEY=<RevenueCat production key>` and is committed. It arrived with the original RevenueCat integration, which was later replaced by YooKassa (`3b9684a`) — but the setup notes were never removed. The same folder's `initialize.dart` also imports the removed `purchases_flutter` package and was one source of the `flutter analyze` errors.

**Near-miss on signing material.** `secrets/` holds `Certificates.p12`, `AuthKey_Q2Q32CN7T9.p8`, `SubscriptionKey_WH6Q4W9JG2.p8`, `Github_Actions.mobileprovision` and `distribution.cer`. `.gitignore` contained `.secrets/` — a leading-dot pattern that matches nothing, since the directory is `secrets/`. The files were untracked only because nobody had run a broad `git add`. `git check-ignore secrets/Certificates.p12` exited non-zero, confirming they were unprotected.

Constraint: the same credentials are also supplied to CI through GitHub Secrets (`DISTRIBUTION_CERTIFICATE_P12`, `APP_STORE_CONNECT_API_KEY`, …), so the local `secrets/` folder is a developer convenience, not the source of truth. It can stay on disk; it must not be committable.

## Goals / Non-Goals

**Goals:**
- Make it impossible to commit signing material by accident.
- Remove the tracked credentials file from the working tree and from history.
- Revoke the exposed key so history purging is not the only line of defence.
- Establish that ignore patterns get verified against real paths.

**Non-Goals:**
- Moving `secrets/` into a secret manager or encrypted store. CI already reads from GitHub Secrets; local convenience storage is acceptable once it is unignorable.
- Auditing history for *other* secrets beyond the known RevenueCat key. Worth doing, but a separate change with a different tool (`gitleaks`/`trufflehog`) and a different risk profile.
- Reworking how CI consumes secrets.

## Decisions

**Match by both directory and extension, not just directory.** `secrets/` alone would leave a `.p12` dropped into `brainy-app/ios/` exposed. Extension patterns are the backstop that survives someone choosing a different folder. Cost is negligible: the repo has no legitimate tracked file with these extensions.

**Keep `.secrets/` in the ignore list.** It is now redundant, but harmless, and removing it invites the reverse mistake if someone later creates a dot-prefixed folder.

**Revoke before purging history.** Purging is slow, coordinated, and easy to get wrong; revocation is instant and unilateral. Doing revocation first means the key is worthless even if the purge is delayed or botched. This ordering is the single most important decision here.

*Alternative considered:* purge first, skip revocation. Rejected — history purging cannot reach clones, forks, GitHub's own unreferenced-object storage, or anyone's local reflog. Revocation is the only remediation that is actually complete.

**Purge with `git filter-repo`, not `filter-branch`.** `filter-branch` is deprecated, dramatically slower, and its documentation now recommends `filter-repo`. BFG is a reasonable alternative but requires a JVM.

*Alternative considered:* do not rewrite history at all, relying on revocation alone. Defensible — the revoked key is inert — but leaves a credential-shaped string in the repo that will be re-flagged by every future secret scan and sets a poor precedent. Rewriting once, early, on a solo project with one open PR is cheap. If the coordination cost is judged too high, revocation alone is an acceptable fallback and this decision can be reversed without affecting the rest of the change.

**Verify with `git check-ignore`, not by reading the file.** The whole defect was a pattern that read correctly and matched nothing. Only execution proves a pattern works.

## Risks / Trade-offs

- **History rewrite breaks every clone and any SHA-pinned reference** → Perform it while the project is effectively single-developer and only one dependabot PR is open. Announce before rewriting. Confirm the open PR is merged or closed first, since rebasing it after the rewrite is more work than landing it before.
- **Revoking the key breaks something unnoticed** → Low: `SubscriptionService.isPremium()` is a hardcoded `false` stub and no code path calls RevenueCat. The `REVENUECAT_API_KEY` GitHub secret is still passed as a `--dart-define` in the fastlane lane, but `AppConstants.revenueCatApiKey` no longer exists, so the value is unused. Grep for both before revoking to confirm.
- **Extension patterns hide a file someone genuinely wants tracked** → Accepted. If it ever happens, `git add -f` is the documented escape hatch, and the friction is the point.
- **Purge misses copies of the key under other paths or older names** → Search history by content (`git log -S`), not only by path, before declaring the purge complete.

## Migration Plan

1. Land the ignore-rule and file-deletion work (already applied in the working tree) on `main`.
2. Revoke and reissue the RevenueCat key. This is independent and can happen immediately.
3. Merge or close the open dependabot PR (`fast-xml-parser 5.5.6 → 5.5.7`).
4. Announce the rewrite; run `git filter-repo`; force-push `main`.
5. Re-clone locally and verify `git log --all -S'<key fragment>'` returns nothing.

**Rollback:** keep a full mirror clone (`git clone --mirror`) taken immediately before step 4. If the rewrite is wrong, force-push the mirror back. Nothing before step 4 needs rollback — ignore rules and file deletions are ordinary reversible commits.

## Decision on history rewriting (2026-08-01)

**Skip the rewrite; rely on revocation.** Delegated to the implementer and decided as follows.

Once the key is revoked it is inert, and revocation is the only remediation that reaches clones,
forks and GitHub's unreferenced-object storage. A rewrite would additionally invalidate every
clone, require force-pushing `main`, and force the open dependabot PR to be rebased — real cost
for a benefit that is largely cosmetic given the key no longer authenticates.

The residue is that a credential-shaped string stays in history and future secret scans will flag
it. That is accepted, and is the reason task 4.2 (add a secret-scanning step) matters more than the
rewrite would have.

**This makes revocation mandatory, not optional.** It is the only thing standing between the leak
and an active credential, and only the account owner can perform it.

## Open Questions
- Should the `REVENUECAT_API_KEY` GitHub secret and its `--dart-define` in the fastlane lane be deleted at the same time? Belongs to `revenuecat-removal-cleanup`, but it is the natural moment to do it.
- Should a secret-scanning step (`gitleaks`) be added to the CI gate so this class of defect is caught automatically? Proposed as a follow-up rather than folded in here.
