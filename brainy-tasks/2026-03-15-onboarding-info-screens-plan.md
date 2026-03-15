# Onboarding Info Screens Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two informational screens to onboarding (Schulte explanation + science backing) between Welcome and data-collection screens.

**Architecture:** Two new stateless page widgets inserted into the existing PageView. Localization strings added to both ARB files. Single constant updated from 5→7.

**Tech Stack:** Flutter, Riverpod, Hive, ARB localization

**Spec:** `brainy-tasks/2026-03-15-onboarding-info-screens-design.md`

---

## Chunk 1: Localization strings + constant update

### Task 1: Add localization strings to ARB files

**Files:**
- Modify: `brainy-app/l10n/app_ru.arb:66` (before `onboardingAlreadySubscribed`)
- Modify: `brainy-app/l10n/app_en.arb:66` (before `onboardingAlreadySubscribed`)

- [ ] **Step 1: Add Russian strings to `app_ru.arb`**

Insert after line 65 (`"onboardingSkipPaywall": "Продолжить без подписки",`):

```json
  "onboardingSchulteTitle": "Таблицы Шульте — тренажёр для мозга",
  "onboardingSchulteSubtitle": "Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!",
  "onboardingSchulteHint": "Найди числа по порядку: 1, 2, 3...",
  "onboardingSchulteBenefit1": "Развивает внимание и концентрацию",
  "onboardingSchulteBenefit2": "Расширяет периферическое зрение",
  "onboardingSchulteBenefit3": "Ускоряет чтение в 1.5–2 раза",
  "onboardingScienceTitle": "Проверено наукой",
  "onboardingScienceSubtitle": "Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания",
  "onboardingScienceFact1Value": "60+ лет",
  "onboardingScienceFact1Label": "используется в нейропсихологии и педагогике",
  "onboardingScienceFact2Value": "2 недели",
  "onboardingScienceFact2Label": "для заметного улучшения скорости чтения при ежедневных занятиях",
  "onboardingScienceFact3Value": "5 мин/день",
  "onboardingScienceFact3Label": "достаточно для результата — не перегружает ребёнка",
```

- [ ] **Step 2: Add English strings to `app_en.arb`**

Insert after line 65 (`"onboardingSkipPaywall": "Continue without subscription",`):

```json
  "onboardingSchulteTitle": "Schulte Tables — Brain Trainer",
  "onboardingSchulteSubtitle": "Find the numbers in order as fast as you can. Bigger grid — harder challenge!",
  "onboardingSchulteHint": "Find the numbers in order: 1, 2, 3...",
  "onboardingSchulteBenefit1": "Builds attention and concentration",
  "onboardingSchulteBenefit2": "Expands peripheral vision",
  "onboardingSchulteBenefit3": "Boosts reading speed 1.5–2×",
  "onboardingScienceTitle": "Backed by Science",
  "onboardingScienceSubtitle": "Developed by German psychiatrist Walter Schulte in the 1960s for attention training",
  "onboardingScienceFact1Value": "60+ years",
  "onboardingScienceFact1Label": "used in neuropsychology and education",
  "onboardingScienceFact2Value": "2 weeks",
  "onboardingScienceFact2Label": "to noticeably improve reading speed with daily practice",
  "onboardingScienceFact3Value": "5 min/day",
  "onboardingScienceFact3Label": "enough for results — won't overwhelm your child",
```

- [ ] **Step 3: Run `flutter gen-l10n` to regenerate localizations**

Run: `cd brainy-app && flutter gen-l10n`

Expected: Files regenerated in `lib/l10n/`, no errors.

- [ ] **Step 4: Commit**

```bash
git add brainy-app/l10n/
git commit -m "feat(onboarding): add localization strings for info screens"
```

### Task 2: Update onboarding page count constant

**Files:**
- Modify: `brainy-app/lib/constants/app_constants.dart:93`

- [ ] **Step 1: Change `onboardingPageCount` from 5 to 7**

In `brainy-app/lib/constants/app_constants.dart`, change line 93:

```dart
// Before:
static const int onboardingPageCount = 5;

// After:
static const int onboardingPageCount = 7;
```

- [ ] **Step 2: Commit**

```bash
git add brainy-app/lib/constants/app_constants.dart
git commit -m "feat(onboarding): update page count from 5 to 7"
```

---

## Chunk 2: Schulte info page (Screen 2)

### Task 3: Create `schulte_info_page.dart`

**Files:**
- Create: `brainy-app/lib/features/onboarding/pages/schulte_info_page.dart`

- [ ] **Step 1: Create the file with full implementation**

Create `brainy-app/lib/features/onboarding/pages/schulte_info_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class SchulteInfoPage extends ConsumerWidget {
  const SchulteInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          _MiniTable(),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingSchulteHint,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingSchulteTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingSchulteSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _BenefitRow(emoji: '🎯', text: l10n.onboardingSchulteBenefit1),
          const SizedBox(height: 14),
          _BenefitRow(emoji: '👁️', text: l10n.onboardingSchulteBenefit2),
          const SizedBox(height: 14),
          _BenefitRow(emoji: '📖', text: l10n.onboardingSchulteBenefit3),
          const Spacer(),
          OnboardingPrimaryButton(
            label: l10n.onboardingNext,
            onPressed: () =>
                ref.read(onboardingProvider.notifier).nextPage(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MiniTable extends StatelessWidget {
  // Fixed layout: [3, 7, 1, 5, 9, 4, 8, 2, 6]
  static const _numbers = [3, 7, 1, 5, 9, 4, 8, 2, 6];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = _numbers[index];
          return _MiniCell(number: number);
        },
      ),
    );
  }
}

class _MiniCell extends StatelessWidget {
  final int number;

  const _MiniCell({required this.number});

  @override
  Widget build(BuildContext context) {
    final isFound = number == 1;
    final isNext = number == 2;

    Color textColor = AppColors.textPrimary;
    Color bgColor = AppColors.surface;
    BoxBorder? border;

    if (isFound) {
      textColor = AppColors.success;
      bgColor = AppColors.success.withAlpha(51); // ~0.2 opacity
      border = Border.all(color: AppColors.success, width: 2);
    } else if (isNext) {
      textColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _BenefitRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(38), // ~0.15 opacity
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd brainy-app && flutter analyze lib/features/onboarding/pages/schulte_info_page.dart`

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add brainy-app/lib/features/onboarding/pages/schulte_info_page.dart
git commit -m "feat(onboarding): add Schulte info page (screen 2)"
```

---

## Chunk 3: Science page (Screen 3)

### Task 4: Create `science_page.dart`

**Files:**
- Create: `brainy-app/lib/features/onboarding/pages/science_page.dart`

- [ ] **Step 1: Create the file with full implementation**

Create `brainy-app/lib/features/onboarding/pages/science_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class SciencePage extends ConsumerWidget {
  const SciencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(38), // ~0.15 opacity
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🧠', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingScienceTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingScienceSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _FactCard(
            value: l10n.onboardingScienceFact1Value,
            label: l10n.onboardingScienceFact1Label,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _FactCard(
            value: l10n.onboardingScienceFact2Value,
            label: l10n.onboardingScienceFact2Label,
            valueColor: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _FactCard(
            value: l10n.onboardingScienceFact3Value,
            label: l10n.onboardingScienceFact3Label,
            valueColor: AppColors.accent,
          ),
          const Spacer(),
          OnboardingPrimaryButton(
            label: l10n.onboardingNext,
            onPressed: () =>
                ref.read(onboardingProvider.notifier).nextPage(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _FactCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd brainy-app && flutter analyze lib/features/onboarding/pages/science_page.dart`

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add brainy-app/lib/features/onboarding/pages/science_page.dart
git commit -m "feat(onboarding): add science backing page (screen 3)"
```

---

## Chunk 4: Wire pages into PageView

### Task 5: Update `onboarding_screen.dart` to include new pages

**Files:**
- Modify: `brainy-app/lib/features/onboarding/screens/onboarding_screen.dart:7-11,68-74`

- [ ] **Step 1: Add imports for new pages**

In `onboarding_screen.dart`, add two imports after the existing page imports (after line 11):

```dart
import '../pages/schulte_info_page.dart';
import '../pages/science_page.dart';
```

- [ ] **Step 2: Insert new pages into PageView children**

In `onboarding_screen.dart`, update the PageView children array (lines 68-74). Insert `SchulteInfoPage()` and `SciencePage()` after `WelcomePage()`:

```dart
children: const [
  WelcomePage(),
  SchulteInfoPage(),
  SciencePage(),
  AgePage(),
  GoalsPage(),
  FrequencyPage(),
  PaywallPage(),
],
```

- [ ] **Step 3: Verify the full project compiles**

Run: `cd brainy-app && flutter analyze`

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add brainy-app/lib/features/onboarding/screens/onboarding_screen.dart
git commit -m "feat(onboarding): wire Schulte info and science pages into PageView"
```

### Task 6: Manual smoke test

- [ ] **Step 1: Run the app and verify onboarding flow**

Run: `cd brainy-app && flutter run`

Verify:
1. Welcome screen appears first — tap "Начать"
2. Schulte info screen appears — mini 3x3 table visible, 3 benefits listed, "Далее" button works
3. Science screen appears — brain emoji, 3 fact cards (purple/teal/yellow values), "Далее" works
4. Age selection screen — functions as before
5. Goals screen — functions as before
6. Frequency screen — functions as before
7. Paywall screen — functions as before
8. Page indicator shows 7 dots
9. Back button works on all screens (goes to previous page)
10. Back on Welcome screen exits app/pops normally

- [ ] **Step 2: Verify English locale**

Switch device language to English, verify all new strings display correctly.

- [ ] **Step 3: Final commit (if any fixes needed)**

If smoke testing required fixes, commit them:

```bash
git add -u
git commit -m "fix(onboarding): address smoke test issues"
```
