import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/league.dart';
import '../providers/game_services_provider.dart';
import '../providers/league_provider.dart';

class LeagueScreen extends ConsumerWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tier = ref.watch(currentLeagueProvider);
    final weeklyXp = ref.watch(weeklyXpProvider);
    final standingsAsync = ref.watch(leagueStandingsProvider);
    final isSignedIn = ref.watch(isGameServicesSignedInProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.leagueTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _TierHeader(tier: tier, l10n: l10n),
            const SizedBox(height: 16),
            _TierProgress(tier: tier, weeklyXp: weeklyXp, l10n: l10n),
            const SizedBox(height: 16),
            if (!isSignedIn) ...[
              _ConnectCard(l10n: l10n, ref: ref),
              const SizedBox(height: 16),
            ],
            standingsAsync.when(
              data: (standings) =>
                  _StandingsList(standings: standings, l10n: l10n),
              loading: () => Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      l10n.leagueLoading,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.leagueError,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            if (isSignedIn) ...[
              const SizedBox(height: 16),
              _FullRankingButton(l10n: l10n, ref: ref),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.leagueResetsMonday,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _ConnectCard({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_esports_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.leagueConnectTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.leagueConnectSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final service = ref.read(gameServicesProvider);
                await service.signIn();
                ref.read(isGameServicesSignedInProvider.notifier).state =
                    service.isSignedIn;
                ref.read(playerNameProvider.notifier).state =
                    service.playerName;
                ref.invalidate(leagueStandingsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                l10n.leagueConnect,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullRankingButton extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _FullRankingButton({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(gameServicesProvider).showNativeLeaderboards();
        },
        icon: const Icon(Icons.leaderboard_rounded, size: 20),
        label: Text(
          l10n.leagueFullRanking,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  final LeagueTier tier;
  final AppLocalizations l10n;

  const _TierHeader({required this.tier, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tier.color.withValues(alpha: 0.2),
            tier.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Image.asset(tier.assetPath, width: 80, height: 80),
          const SizedBox(height: 12),
          Text(
            tier.title(l10n),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: tier.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.leagueTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierProgress extends StatelessWidget {
  final LeagueTier tier;
  final int weeklyXp;
  final AppLocalizations l10n;

  const _TierProgress({
    required this.tier,
    required this.weeklyXp,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final next = tier.nextTier;
    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: tier.color, size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.leagueMaxTier,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    final progressInTier = weeklyXp - tier.xpThreshold;
    final tierRange = next.xpThreshold - tier.xpThreshold;
    final fraction = (progressInTier / tierRange).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(tier.assetPath, width: 24, height: 24),
              const Spacer(),
              Text(
                l10n.leagueWeeklyXp(weeklyXp),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              Image.asset(next.assetPath, width: 24, height: 24),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.leagueNextTier(
                next.xpThreshold - weeklyXp, next.title(l10n)),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsList extends StatelessWidget {
  final List<LeaguePlayer> standings;
  final AppLocalizations l10n;

  const _StandingsList({required this.standings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < standings.length; i++)
            _PlayerRow(
              rank: i + 1,
              player: standings[i],
              l10n: l10n,
              isLast: i == standings.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final int rank;
  final LeaguePlayer player;
  final AppLocalizations l10n;
  final bool isLast;

  const _PlayerRow({
    required this.rank,
    required this.player,
    required this.l10n,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: player.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.background,
                  width: 1,
                ),
              ),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color:
                    rank <= 3 ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.isCurrentUser ? l10n.leagueYou : player.name,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight:
                    player.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                color: player.isCurrentUser
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${player.weeklyXp} XP',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: player.isCurrentUser
                  ? AppColors.secondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
