## Decision / Outcome (2026-10-25)

- **No history rewrite** (decision 3.1, 2026-08-01, below). The leaked RevenueCat keys may remain in history; they are remediated by revocation only. All history-purge text further down is **superseded** and kept for the record.
- **No replacement key, ever.** Owner decision: the app is fully free and RevenueCat is not needed.
- **Revocation is mandatory and pending (External).** Scope: the key in `credentials.md` (history: `e1ad601`) and the RevenueCat iOS SDK key that sat in `brainy-app/lib/constants/app_constants.dart` (added `5da142d`, commented copy in `3b9684a`, removed in `f0e1ec8`). Also delete the `REVENUECAT_API_KEY` GitHub secret and confirm the old keys no longer authenticate.
- **CI secret scan added** (former open question): `secrets-scan` job in `.github/workflows/ci.yml` runs gitleaks 8.30.1 over full history (`fetch-depth: 0`, `--redact`) with `.gitleaks.toml`. The allowlist covers only the public Firebase iOS config (`brainy-app/lib/firebase_options.dart`, `brainy-app/ios/Runner/GoogleService-Info.plist`) for rules `gcp-api-key` / `generic-api-key`. A local run over history reports no leaks. gitleaks does **not** detect the historic RevenueCat keys, so the scanner does not replace revocation.
- **`REVENUECAT_API_KEY` plumbing removed** (former open question) from the Fastfile and workflows in `9180bab`.
- **`check-ignore` rule** recorded in `CLAUDE.md` Architecture Rules (`faf276b`).
- Optional External: restrict the Firebase iOS API key in Google Cloud (bundle ID + API restrictions); it is public by design.

---

*Original 2026-08-01 design follows, kept for history. Where it conflicts with the section above, the section above wins.*

## Context

Two independent exposures were found during the 2026-08-01 audit.

**Tracked credential.** `brainy-app/docs/setup/revenue_cat/credentials.md` contains `API_KEY=<RevenueCat key>` and is committed. It arrived with the original RevenueCat integration, which was later replaced by YooKassa (`3b9684a`) — but the setup notes were never removed. *(Historical: YooKassa was later dropped too; the app is now fully free.)* The same folder's `initialize.dart` also imports the removed `purchases_flutter` package and was one source of the `flutter analyze` errors.

**Near-miss on signing material.** `secrets/` holds `Certificates.p12`, `AuthKey_Q2Q32CN7T9.p8`, `SubscriptionKey_WH6Q4W9JG2.p8`, `Github_Actions.mobileprovision` and `distribution.cer`. `.gitignore` contained `.secrets/` — a leading-dot pattern that matches nothing, since the directory is `secrets/`. The files were untracked only because nobody had run a broad `git add`. `git check-ignore secrets/Certificates.p12` exited non-zero, confirming they were unprotected.

Constraint: the same credentials are also supplied to CI through GitHub Secrets (`DISTRIBUTION_CERTIFICATE_P12`, `APP_STORE_CONNECT_API_KEY`, …), so the local `secrets/` folder is a developer convenience, not the source of truth. It can stay on disk; it must not be committable.

## Goals / Non-Goals

**Goals:**
- Make it impossible to commit signing material by accident.
- Remove the tracked credentials file from the working tree. ~~and from history~~ — superseded by decision 3.1.
- Revoke the exposed key ~~so history purging is not the only line of defence~~ — it is the only line of defence, since history is not purged.
- Establish that ignore patterns get verified against real paths.

**Non-Goals:**
- Moving `secrets/` into a secret manager or encrypted store. CI already reads from GitHub Secrets; local convenience storage is acceptable once it is unignorable.
- ~~Auditing history for *other* secrets beyond the known RevenueCat key.~~ Partly done after all: the gitleaks CI job scans full history, and a manual content search found the second RevenueCat key in `app_constants.dart` history.
- Reworking how CI consumes secrets.

## Decisions

**Match by both directory and extension, not just directory.** `secrets/` alone would leave a `.p12` dropped into `brainy-app/ios/` exposed. Extension patterns are the backstop that survives someone choosing a different folder. Cost is negligible: the repo has no legitimate tracked file with these extensions.

**Keep `.secrets/` in the ignore list.** It is now redundant, but harmless, and removing it invites the reverse mistake if someone later creates a dot-prefixed folder.

**Revoke before purging history.** *(Superseded: there is no purge; revocation is the whole remediation.)* Purging is slow, coordinated, and easy to get wrong; revocation is instant and unilateral.

*Alternative considered:* purge first, skip revocation. Rejected — history purging cannot reach clones, forks, GitHub's own unreferenced-object storage, or anyone's local reflog. Revocation is the only remediation that is actually complete.

~~**Purge with `git filter-repo`, not `filter-branch`.**~~ *Superseded by decision 3.1 — no purge is performed.* The original reasoning (filter-repo over the deprecated filter-branch; BFG needs a JVM) and the "revocation alone" alternative are kept for the record; the alternative is what was chosen.

**Verify with `git check-ignore`, not by reading the file.** The whole defect was a pattern that read correctly and matched nothing. Only execution proves a pattern works.

**Allowlist only public Firebase config in the scanner.** Firebase iOS API keys ship in every build and identify the app; they are not secrets. Allowlisting them by path and rule keeps the scan green without hiding any real credential class.

## Risks / Trade-offs

- ~~**History rewrite breaks every clone and any SHA-pinned reference**~~ — moot, no rewrite.
- **Revoking the key breaks something unnoticed** → None: no code path, Fastfile lane or workflow references RevenueCat (verified by grep, 2026-10-25). *(Historical: at proposal time `SubscriptionService.isPremium()` was a hardcoded stub; it has since been deleted.)*
- **Extension patterns hide a file someone genuinely wants tracked** → Accepted. If it ever happens, `git add -f` is the documented escape hatch, and the friction is the point.
- **Copies of the key under other paths or older names** → Confirmed real: `app_constants.dart` history held a second RevenueCat key. Revocation scope covers it.
- **Key-shaped strings stay in history** → Accepted (decision 3.1). gitleaks does not flag them; revocation makes them inert.

## Migration Plan

1. Land the ignore-rule and file-deletion work — done (`f0e1ec8`).
2. Revoke the RevenueCat keys — External, pending. No reissue.
3. ~~Merge or close the open dependabot PR~~ — dropped (3.1).
4. ~~Announce the rewrite; run `git filter-repo`; force-push `main`~~ — dropped (3.1).
5. ~~Re-clone locally and verify `git log --all -S'<key fragment>'` returns nothing~~ — dropped (3.1); history intentionally still contains the revoked keys.

**Rollback:** nothing to roll back — ignore rules, deletions and the CI job are ordinary reversible commits.

## Decision on history rewriting (2026-08-01)

**Skip the rewrite; rely on revocation.** Delegated to the implementer and decided as follows.

Once the key is revoked it is inert, and revocation is the only remediation that reaches clones,
forks and GitHub's unreferenced-object storage. A rewrite would additionally invalidate every
clone, require force-pushing `main`, and force the open dependabot PR to be rebased — real cost
for a benefit that is largely cosmetic given the key no longer authenticates.

The residue is that a credential-shaped string stays in history and future secret scans may flag
it. That is accepted, and is the reason task 4.2 (add a secret-scanning step) matters more than the
rewrite would have.

**This makes revocation mandatory, not optional.** It is the only thing standing between the leak
and an active credential, and only the account owner can perform it.

## Open Questions

None. Both former questions are resolved: the `REVENUECAT_API_KEY` `--dart-define` and workflow plumbing are removed (GitHub secret deletion is External), and the gitleaks CI step is added.
