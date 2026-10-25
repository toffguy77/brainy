## Context

Monetization was attempted twice and abandoned twice. RevenueCat came first and was commented out when Apple blocked the Paid Applications Agreement for Russian accounts. YooKassa replaced it (`3b9684a`): four Cloud Functions were written and tested (33 passing tests) but never deployed, and no credentials were ever configured. What shipped is a stub — `SubscriptionService.isPremium()` returns a literal `false`.

The consequence is that the gating logic is live while the unlock path is not. Every `isPremium` branch in the app resolves to the locked side for every user, permanently. Eleven call sites in `home_screen.dart` alone, plus the character screen, accessories screen, game screen, parent dashboard and progress screen. Gorbov-Schulte mode — a fully implemented second game mode with pure, unit-tested grid generation and tap logic — is unreachable. So is half the grid-size range.

The decision to ship free resolves this by deletion rather than by flipping a flag.

## Goals / Non-Goals

**Goals:**
- Make every implemented feature reachable.
- Remove the concept of a paid tier from code, tests, plans and store metadata — not just disable it.
- Eliminate the payment backend and the vulnerability surface it carries.
- Preserve every existing user's local progress.

**Non-Goals:**
- Ads, or any other monetization. "Free" here means no revenue mechanism at all.
- Keeping a feature flag for a possible future paid tier. Reintroducing one later is a fresh change; a dormant flag would rot exactly as the current one did.
- Server-side accounts or cloud sync. Deleting `functions/` leaves the app fully local plus Game Center, which is what it already is in practice.

## Decisions

**Delete the gating, do not stub `isPremium()` to `true`.** Returning `true` would unlock everything in one line, and is tempting. It is rejected because it leaves every branch, every lock icon, every bottom-sheet call site and every test in the tree as dead-but-live code — the same trap that produced the current state. A one-line change also silently keeps `purchases`-shaped concepts in the plans and metadata. Deletion is more work once and less work forever.

**Delete `functions/` entirely rather than patch its dependencies.** All four exports are payment-only; nothing else imports the package. Deleting it resolves the 23 npm advisories (2 critical) by removing the code that carries them, which is strictly better than upgrading dependencies of a package that will never deploy. If a Cloud Function is needed later, it starts from a clean package.

*Alternative considered:* keep `functions/` and run `npm audit fix`. Rejected — it preserves maintenance cost, dependabot noise and CI time for code with no consumer.

**Give Pixel a real unlock condition instead of granting it outright.** Pixel is currently `UnlockType.premium`. Making it free-on-start would shrink the collection loop from five characters to a four-plus-one freebie. Assigning it an achievable condition (an XP level or streak, consistent with Zap/Vortex/Glitch) preserves the progression the character system is built around. The specific condition is an open question below.

**Move the notification-permission request off the deleted paywall page.** The onboarding paywall page (page 7) currently does two unrelated things: requests notification permission and upsells. Deleting the page must not delete the permission request — it is the app's only prompt, and losing it silently disables all reminders for new users. It moves to the frequency page (page 6), which is thematically adjacent since it already asks how often the child will train.

**Delete `subscription.md` rather than rewrite it.** Plans are described as living documentation of how the app behaves. A plan for a capability that does not exist is not living documentation.

**Keep tolerating stale Hive subscription keys.** Hive boxes are read by key; unknown leftover keys are inert. No migration is needed — only a test asserting that a box containing them still opens.

## Risks / Trade-offs

- **Onboarding page count changes from 7 to 6** → `AppConstants.onboardingPageCount`, the page indicator and `onboarding` tests all reference it. Change the constant, not the literal, and verify the indicator renders six dots.
- **Deleting `lib/features/subscription/` breaks imports across six screens** → Compiler catches all of them; `flutter analyze` must be clean before the change is considered done.
- **App Store review may query the removal of in-app purchases** → Low risk; removing IAP is not a reviewable regression. Note that the last rejection (2.3.8) concerned kids/children wording, not monetization, so the description edits must not reintroduce that language.
- **Users who expected a paid tier from the Telegram waitlist** → The waitlist link is removed. Worth a post in that channel announcing the app is free, though that is outside the repo.
- **Deleting `functions/` also deletes 33 passing tests** → Accepted; they test code being removed. This drops the CI `functions` job from `ci-quality-gate`, which must be updated in the same change or immediately after.

## Migration Plan

1. Remove gating from the feature surfaces (home, game, character, accessories, parent, progress) so everything is reachable while the paywall still exists — the app is fully usable at every intermediate commit.
2. Delete the paywall screen, onboarding paywall page and premium bottom sheet; relocate the notification-permission request; adjust `onboardingPageCount`.
3. Delete `SubscriptionService`, `isPremiumProvider`, subscription constants and l10n strings.
4. Delete `functions/`, its `firebase.json` entry and the `subscriptions` Firestore index; drop the `functions` job from CI.
5. Update store metadata and plans.
6. Run `flutter analyze` and `flutter test` clean, then build.

**Rollback:** every step is an ordinary revert. Nothing here writes to user data or to a remote service, so there is no state to unwind. The only non-revertible action is deploying updated App Store metadata, which happens last and is itself editable.

## Open Questions

- What unlock condition should Pixel get? Level 20 (the top of `xpThresholds`) makes it the long-tail reward; a 14-day streak sits between Vortex (30) and the early characters. Needs a product call.
- Should the two formerly-premium accessories keep their coin prices, or be repriced now that the coin economy has a second sink? Depends on `accessories-shop-completion`, which makes the shop reachable at all.
- Does the `deploy-testflight.yml` path filter need updating once `functions/` is gone?
