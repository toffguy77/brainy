import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/character.dart';
import '../../../models/user_progress.dart';
import '../../game/providers/user_progress_provider.dart';
import '../data/characters_data.dart';
import '../providers/character_provider.dart';

Widget characterAvatar(String id, {required double size, Color? color}) {
  final info = defaultCharacters.firstWhere(
    (c) => c.id == id,
    orElse: () => defaultCharacters.first,
  );
  return Image.asset(
    info.assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    color: color,
    errorBuilder: (_, __, ___) => Icon(
      Icons.face_rounded,
      size: size,
      color: color ?? AppColors.textSecondary,
    ),
  );
}

class CharacterScreen extends ConsumerStatefulWidget {
  const CharacterScreen({super.key});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _bobController;
  late final Animation<double> _bobAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final activeId = ref.read(userProgressProvider).activeCharacterId;
    final activeIndex =
        defaultCharacters.indexWhere((c) => c.id == activeId);
    _currentPage = activeIndex >= 0 ? activeIndex : 0;

    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: _currentPage,
    );

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

  }

  @override
  void dispose() {
    _pageController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  CharacterData _findCharacterData(
      List<CharacterData> characters, String id) {
    return characters.firstWhere(
      (c) => c.id == id,
      orElse: () => characters.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(userProgressProvider);
    final characters = ref.watch(characterProvider);
    final activeInfo = defaultCharacters[_currentPage];
    final activeData = _findCharacterData(characters, activeInfo.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.characterScreenTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCharacterPreview(activeInfo, activeData),
                const SizedBox(height: 12),
                Text(
                  activeInfo.name(l10n),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeInfo.description(l10n),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: defaultCharacters.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final info = defaultCharacters[index];
                      final data = _findCharacterData(characters, info.id);
                      final isActive = progress.activeCharacterId == info.id;
                      return _CharacterCard(
                        info: info,
                        isUnlocked: data.isUnlocked,
                        isActive: isActive,
                        onTap: () =>
                            _onCharacterTap(info, data, progress, l10n),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildPageIndicator(),
                const SizedBox(height: 24),
                if (activeData.isUnlocked) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          key: const Key('accessoriesButton'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/accessories'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.accessoriesCustomize,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildActionButton(
                    activeInfo, activeData, progress, l10n),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterPreview(CharacterInfo info, CharacterData data) {
    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: data.isUnlocked
              ? LinearGradient(
                  colors: [
                    info.color.withValues(alpha: 0.8),
                    info.color.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: data.isUnlocked ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(80),
          border: Border.all(
            color: data.isUnlocked ? info.color : AppColors.surface,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: data.isUnlocked
              ? characterAvatar(info.id, size: 80)
              : ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 0.5, 0,
                  ]),
                  child: characterAvatar(info.id, size: 80),
                ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        defaultCharacters.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? defaultCharacters[index].color
                : AppColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    CharacterInfo info,
    CharacterData data,
    UserProgress progress,
    AppLocalizations l10n,
  ) {
    if (!data.isUnlocked) {
      return _ActionButton(
        label: info.unlockCondition(l10n),
        color: AppColors.surface,
        onTap: null,
      );
    }

    if (progress.activeCharacterId == info.id) {
      return _ActionButton(
        label: l10n.characterSelected,
        color: AppColors.surface,
        onTap: null,
      );
    }

    return _ActionButton(
      label: l10n.characterSelect,
      color: AppColors.primary,
      onTap: () =>
          ref.read(characterProvider.notifier).selectCharacter(info.id),
    );
  }

  void _onCharacterTap(
    CharacterInfo info,
    CharacterData data,
    UserProgress progress,
    AppLocalizations l10n,
  ) {
    if (!data.isUnlocked) {
      _showLockedBottomSheet(info, l10n);
      return;
    }
    if (progress.activeCharacterId != info.id) {
      ref.read(characterProvider.notifier).selectCharacter(info.id);
    }
  }

  void _showLockedBottomSheet(
    CharacterInfo info,
    AppLocalizations l10n,
  ) {
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
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 0.6, 0,
                ]),
                child: characterAvatar(info.id, size: 64),
              ),
              const SizedBox(height: 16),
              Text(
                info.name(l10n),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info.description(l10n),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  info.unlockCondition(l10n),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: info.color,
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

class _CharacterCard extends StatelessWidget {
  final CharacterInfo info;
  final bool isUnlocked;
  final bool isActive;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.info,
    required this.isUnlocked,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isUnlocked
              ? info.color.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? info.color
                : isUnlocked
                    ? info.color.withValues(alpha: 0.3)
                    : Colors.transparent,
            width: isActive ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: isUnlocked
                  ? characterAvatar(info.id, size: 56)
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 0.4, 0,
                      ]),
                      child: characterAvatar(info.id, size: 56),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              info.name(l10n),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            if (!isUnlocked)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    info.unlockCondition(l10n),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            else if (isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: info.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
