import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/game_modes.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/game_mode_text.dart';

/// The mode the statistics screens show. Shared by the progress screen,
/// grid detail and the parent dashboard so switching sticks across them.
final statsModeProvider = StateProvider<String>((ref) => GameModes.classic);

/// A row of chips selecting [statsModeProvider].
class ModeFilterChips extends ConsumerWidget {
  const ModeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(statsModeProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mode in GameModes.all)
          ChoiceChip(
            key: ValueKey('statsMode-$mode'),
            label: Text(
              gameModeLabel(l10n, mode),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: mode == selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            selected: mode == selected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            showCheckmark: false,
            onSelected: (_) =>
                ref.read(statsModeProvider.notifier).state = mode,
          ),
      ],
    );
  }
}
