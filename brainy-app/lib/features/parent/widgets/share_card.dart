import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/providers/records_provider.dart';
import '../../game/providers/user_progress_provider.dart';

class ShareCard extends StatelessWidget {
  final int streakDays;
  final int? best5x5;
  final AppLocalizations l10n;

  const ShareCard({
    super.key,
    required this.streakDays,
    required this.best5x5,
    required this.l10n,
  });

  static Future<void> showAndShare(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.read(userProgressProvider);
    final records = ref.read(recordsProvider);

    final box = context.findRenderObject() as RenderBox?;
    final sharePosition =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    final controller = ScreenshotController();
    final widget = ShareCard(
      streakDays: progress.currentStreak,
      best5x5: records[recordKey('classic', 5)],
      l10n: l10n,
    );

    final captureWidget = InheritedTheme.captureAll(
      context,
      Material(
        color: Colors.transparent,
        child: widget,
      ),
    );

    final Uint8List imageBytes = await controller.captureFromLongWidget(
      captureWidget,
      pixelRatio: 3.0,
      delay: const Duration(milliseconds: 100),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/brainy_progress.png');
    await file.writeAsBytes(imageBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: sharePosition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Brainy',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              height: 1),
          const SizedBox(height: 20),
          // Training days
          Text(
            l10n.parentShareCardTitle(streakDays),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareStatItem(
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
                value: '$streakDays',
                label: l10n.parentStreak,
              ),
              if (best5x5 != null)
                _ShareStatItem(
                  icon: Icons.timer_rounded,
                  iconColor: AppColors.secondary,
                  value: '${best5x5}s',
                  label: l10n.parentShareBest5x5,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              height: 1),
          const SizedBox(height: 12),
          Text(
            l10n.parentShareDownload,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareStatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _ShareStatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
