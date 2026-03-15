import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/accessory.dart';
import '../../../shared/services/subscription_service.dart';
import '../../game/providers/user_progress_provider.dart';
import '../data/accessories_data.dart';
import '../data/characters_data.dart';
import '../providers/character_provider.dart';
import 'character_screen.dart';

class AccessoriesScreen extends ConsumerStatefulWidget {
  const AccessoriesScreen({super.key});

  @override
  ConsumerState<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends ConsumerState<AccessoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    AccessorySlot.hat,
    AccessorySlot.glasses,
    AccessorySlot.effect,
    AccessorySlot.cape,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AccessoryInfo> _accessoriesForSlot(AccessorySlot slot) =>
      defaultAccessories.where((a) => a.slot == slot).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(userProgressProvider);
    final characters = ref.watch(characterProvider);
    final activeId = progress.activeCharacterId;
    final activeCharacter = characters.firstWhere(
      (c) => c.id == activeId,
      orElse: () => characters.first,
    );
    final activeInfo = defaultCharacters.firstWhere(
      (c) => c.id == activeId,
      orElse: () => defaultCharacters.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.accessoriesTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${progress.coins}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _CharacterPreview(
            characterInfo: activeInfo,
            equippedHat: activeCharacter.equippedHat,
            equippedGlasses: activeCharacter.equippedGlasses,
            equippedEffect: activeCharacter.equippedEffect,
            equippedCape: activeCharacter.equippedCape,
          ),
          const SizedBox(height: 20),
          _buildTabBar(l10n),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((slot) {
                return _AccessoryGrid(
                  accessories: _accessoriesForSlot(slot),
                  slot: slot,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return TabBar(
      controller: _tabController,
      isScrollable: false,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: l10n.accessoriesTabHats),
        Tab(text: l10n.accessoriesTabGlasses),
        Tab(text: l10n.accessoriesTabEffects),
        Tab(text: l10n.accessoriesTabCapes),
      ],
    );
  }
}

class _CharacterPreview extends StatelessWidget {
  final CharacterInfo characterInfo;
  final String? equippedHat;
  final String? equippedGlasses;
  final String? equippedEffect;
  final String? equippedCape;

  const _CharacterPreview({
    required this.characterInfo,
    this.equippedHat,
    this.equippedGlasses,
    this.equippedEffect,
    this.equippedCape,
  });

  AccessoryInfo? _findAccessory(String? id) {
    if (id == null) return null;
    try {
      return defaultAccessories.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final hat = _findAccessory(equippedHat);
    final glasses = _findAccessory(equippedGlasses);
    final effect = _findAccessory(equippedEffect);
    final cape = _findAccessory(equippedCape);
    final equipped = [hat, glasses, effect, cape].whereType<AccessoryInfo>();

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                characterInfo.color.withValues(alpha: 0.8),
                characterInfo.color.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: characterInfo.color, width: 3),
          ),
          child: Icon(
            characterIcon(characterInfo.id),
            size: 60,
            color: Colors.white,
          ),
        ),
        if (equipped.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: equipped.map((a) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  a.name(locale),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _AccessoryGrid extends ConsumerWidget {
  final List<AccessoryInfo> accessories;
  final AccessorySlot slot;

  const _AccessoryGrid({
    required this.accessories,
    required this.slot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: accessories.length,
      itemBuilder: (context, index) {
        return _AccessoryCard(accessory: accessories[index]);
      },
    );
  }
}

class _AccessoryCard extends ConsumerWidget {
  final AccessoryInfo accessory;

  const _AccessoryCard({required this.accessory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final progress = ref.watch(userProgressProvider);
    final characters = ref.watch(characterProvider);
    final activeId = progress.activeCharacterId;
    final activeCharacter = characters.firstWhere(
      (c) => c.id == activeId,
      orElse: () => characters.first,
    );

    final isOwned = progress.unlockedAccessories.contains(accessory.id);
    final equippedId = switch (accessory.slot) {
      AccessorySlot.hat => activeCharacter.equippedHat,
      AccessorySlot.glasses => activeCharacter.equippedGlasses,
      AccessorySlot.effect => activeCharacter.equippedEffect,
      AccessorySlot.cape => activeCharacter.equippedCape,
    };
    final isEquipped = equippedId == accessory.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEquipped
              ? AppColors.success
              : isOwned
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
          width: isEquipped ? 2.5 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onTap(context, ref, isOwned, isEquipped),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(isOwned),
                const SizedBox(height: 10),
                Text(
                  accessory.name(locale),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isOwned
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(l10n, isOwned, isEquipped),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isOwned) {
    final iconData = switch (accessory.slot) {
      AccessorySlot.hat => Icons.checkroom_rounded,
      AccessorySlot.glasses => Icons.visibility_rounded,
      AccessorySlot.effect => Icons.auto_awesome_rounded,
      AccessorySlot.cape => Icons.shield_rounded,
    };

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isOwned
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        iconData,
        size: 28,
        color: isOwned ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatusChip(
      AppLocalizations l10n, bool isOwned, bool isEquipped) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              l10n.accessoriesEquipped,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    if (isOwned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.accessoriesEquip,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (accessory.isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              l10n.accessoriesPremiumOnly,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded,
              size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            '${accessory.price}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    bool isOwned,
    bool isEquipped,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.read(userProgressProvider);
    final activeId = progress.activeCharacterId;

    if (isEquipped) {
      // Unequip
      HapticFeedback.lightImpact();
      await ref
          .read(characterProvider.notifier)
          .unequipAccessory(activeId, accessory.slot);
      return;
    }

    if (isOwned) {
      // Equip (replaces current)
      HapticFeedback.lightImpact();
      await ref
          .read(characterProvider.notifier)
          .equipAccessory(activeId, accessory.id, accessory.slot);
      return;
    }

    // Not owned — attempt purchase
    if (accessory.isPremium) {
      final hasPremium = await SubscriptionService.isPremium();
      if (!hasPremium) {
        if (context.mounted) {
          _showPremiumDialog(context, l10n);
        }
        return;
      }
      // Premium subscriber gets it free
      await ref
          .read(userProgressProvider.notifier)
          .purchaseAccessory(accessory.id, 0);
      HapticFeedback.mediumImpact();
      await ref
          .read(characterProvider.notifier)
          .equipAccessory(activeId, accessory.id, accessory.slot);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.accessoriesPurchased,
              style: const TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Purchase with coins
    final success = await ref
        .read(userProgressProvider.notifier)
        .purchaseAccessory(accessory.id, accessory.price);

    if (success) {
      HapticFeedback.mediumImpact();
      await ref
          .read(characterProvider.notifier)
          .equipAccessory(activeId, accessory.id, accessory.slot);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.accessoriesPurchased,
              style: const TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (context.mounted) {
      _showNotEnoughCoinsDialog(
          context, l10n, ref.read(userProgressProvider).coins);
    }
  }

  void _showNotEnoughCoinsDialog(
      BuildContext context, AppLocalizations l10n, int balance) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.monetization_on_rounded,
                size: 48,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.accessoriesNotEnoughCoins,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.accessoriesNotEnoughCoinsMessage(
                    accessory.price, balance),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showPremiumDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.lock_rounded,
                size: 48,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.accessoriesPremiumOnly,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (context.mounted) context.go('/paywall');
                      },
                      child: Center(
                        child: Text(
                          l10n.characterUnlockPremium,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
