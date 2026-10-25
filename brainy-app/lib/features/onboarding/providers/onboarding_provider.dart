import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_constants.dart';
import '../../../shared/services/notification_service.dart';
import '../../game/providers/user_progress_provider.dart';

class OnboardingState {
  final int currentPage;
  final String? childAge;
  final List<String> goals;
  final int? dailyGoalMinutes;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.childAge,
    this.goals = const [],
    this.dailyGoalMinutes,
    this.isCompleted = false,
  });

  bool get canAdvanceFromGoals => goals.isNotEmpty;

  OnboardingState copyWith({
    int? currentPage,
    String? childAge,
    List<String>? goals,
    int? dailyGoalMinutes,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      childAge: childAge ?? this.childAge,
      goals: goals ?? this.goals,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final box = Hive.box(AppConstants.userBox);
    return OnboardingState(
      childAge: box.get(AppConstants.userKeyChildAge) as String?,
      goals: (box.get(AppConstants.userKeyGoals) as List?)?.cast<String>() ??
          const [],
      dailyGoalMinutes:
          box.get(AppConstants.userKeyDailyGoalMinutes) as int?,
      isCompleted:
          box.get(AppConstants.userKeyOnboardingCompleted) as bool? ?? false,
    );
  }

  void nextPage() {
    if (state.currentPage < AppConstants.onboardingPageCount - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setChildAge(String age) {
    state = state.copyWith(childAge: age);
  }

  void toggleGoal(String goal) {
    final updated = List<String>.from(state.goals);
    if (updated.contains(goal)) {
      updated.remove(goal);
    } else {
      updated.add(goal);
    }
    state = state.copyWith(goals: updated);
  }

  void setDailyGoalMinutes(int minutes) {
    state = state.copyWith(dailyGoalMinutes: minutes);
  }

  Future<void> completeOnboarding() async {
    final box = Hive.box(AppConstants.userBox);
    await box.put(AppConstants.userKeyChildAge, state.childAge);
    await box.put(AppConstants.userKeyGoals, state.goals);
    await box.put(AppConstants.userKeyDailyGoalMinutes, state.dailyGoalMinutes);
    await box.put(AppConstants.userKeyOnboardingCompleted, true);

    await ref.read(userProgressProvider.notifier).migrateFromOnboarding(
          childAge: state.childAge ?? '',
          goals: state.goals,
          dailyGoalMinutes:
              state.dailyGoalMinutes ?? AppConstants.recommendedFrequencyMinutes,
        );

    // Request notification permission and enable notifications
    final granted = await NotificationService.requestPermission();
    if (granted) {
      await box.put(AppConstants.notificationsEnabledKey, true);
      await NotificationService.rescheduleFromStorage();
    }

    state = state.copyWith(isCompleted: true);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
        OnboardingNotifier.new);
