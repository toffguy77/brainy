import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/parent_provider.dart';
import '../../game/providers/user_progress_provider.dart';

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(parentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.go('/parent/dashboard'),
        ),
        title: Text(
          l10n.parentSettingsTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsCard(
            children: [
              _SettingsLabel(l10n.parentGridSizeMode),
              const SizedBox(height: 8),
              _SegmentedControl(
                options: [l10n.parentGridSizeAuto, l10n.parentGridSizeFixed],
                selectedIndex: settings.gridSizeMode == AppConstants.gridSizeModeAuto ? 0 : 1,
                onChanged: (index) {
                  final mode = index == 0 ? AppConstants.gridSizeModeAuto : AppConstants.gridSizeModeFixed;
                  ref.read(parentProvider.notifier).setGridSizeMode(mode);
                },
              ),
              if (settings.gridSizeMode == AppConstants.gridSizeModeFixed) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: AppConstants.pickerGridSizes.map((size) {
                    final isSelected = settings.fixedGridSize == size;
                    return ChoiceChip(
                      label: Text(
                        '$size×$size',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      side: BorderSide.none,
                      onSelected: (_) {
                        ref
                            .read(parentProvider.notifier)
                            .setFixedGridSize(size);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsLabel(l10n.settingsDailyGoal),
              const SizedBox(height: 8),
              _SegmentedControl(
                options: [
                  for (final m in AppConstants.frequencyOptions)
                    l10n.settingsMinutes(m),
                ],
                selectedIndex: AppConstants.frequencyOptions
                    .indexOf(ref.watch(userProgressProvider).dailyGoalMinutes)
                    .clamp(0, AppConstants.frequencyOptions.length - 1),
                onChanged: (index) => ref
                    .read(userProgressProvider.notifier)
                    .setDailyGoalMinutes(AppConstants.frequencyOptions[index]),
              ),
            ],
          ),          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SettingsLabel(l10n.settingsSounds),
                  Switch(
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      ref
                          .read(parentProvider.notifier)
                          .setSoundEnabled(value);
                    },
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: AppColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SettingsLabel(l10n.settingsHaptic),
                  Switch(
                    value: settings.hapticEnabled,
                    onChanged: (value) {
                      ref
                          .read(parentProvider.notifier)
                          .setHapticEnabled(value);
                    },
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SettingsLabel(l10n.parentNotifications),
                  Switch(
                    value: settings.notificationsEnabled,
                    onChanged: (value) async {
                      final messenger = ScaffoldMessenger.of(context);
                      final applied = await ref
                          .read(parentProvider.notifier)
                          .setNotificationsEnabled(value);
                      if (!applied) {
                        messenger.showSnackBar(SnackBar(
                          content: Text(l10n.settingsNotificationsDenied),
                        ));
                      }
                    },
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: AppColors.textPrimary,
                  ),
                ],
              ),
              if (settings.notificationsEnabled) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.customReminderHour,
                        minute: settings.customReminderMinute,
                      ),
                    );
                    if (picked != null) {
                      ref
                          .read(parentProvider.notifier)
                          .setCustomReminderTime(picked.hour, picked.minute);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.settingsReminderTime,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${settings.customReminderHour.toString().padLeft(2, '0')}:${settings.customReminderMinute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (!settings.hasCustomReminderTime) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${l10n.settingsDefaultTime})',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (settings.hasCustomReminderTime) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(parentProvider.notifier)
                            .clearCustomReminderTime();
                      },
                      child: Text(
                        l10n.settingsResetTime,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsButton(
                icon: Icons.lock_rounded,
                label: l10n.parentChangePin,
                onTap: () => context.go('/parent/pin?mode=change'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsButton(
                icon: Icons.privacy_tip_rounded,
                label: l10n.settingsPrivacyPolicy,
                onTap: () => _openLink(l10n.privacyPolicyUrl),
              ),
              _SettingsButton(
                icon: Icons.description_rounded,
                label: l10n.settingsTerms,
                onTap: () => _openLink(l10n.termsUrl),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final info = snapshot.data!;
              final versionText = l10n.appVersionLabel(
                info.version,
                info.buildNumber,
              );
              return GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: versionText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.versionCopied),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    versionText,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SettingsLabel extends StatelessWidget {
  final String text;
  const _SettingsLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Open a legal page in the system browser. The URL is per-language and
/// comes from ARB.
Future<void> _openLink(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
