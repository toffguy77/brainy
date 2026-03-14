# Задание 2.2 — Игровой экран

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 2.1.

---

## Цель

Реализовать полный игровой экран: сетка Шульте, таймер, обратный отсчёт, анимации тапов, пауза. Экран должен быть красивым, отзывчивым и работать с провайдером из задания 2.1.

---

## Игровой экран

### `lib/features/game/screens/game_screen.dart`

Экран состоит из трёх зон:
1. **Хедер** — таймер + пауза + текущее число для поиска
2. **Сетка** — квадратная, занимает максимум пространства
3. **Футер** — прогресс-бар (найдено X из N)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/records_provider.dart';
import '../providers/sessions_provider.dart';
import '../widgets/schulte_grid.dart';
import '../widgets/game_header.dart';
import '../widgets/countdown_overlay.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int gridSize;
  final String mode;

  const GameScreen({
    super.key,
    this.gridSize = 5,
    this.mode = 'classic',
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initGame(
            gridSize: widget.gridSize,
            mode: widget.mode,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Когда игра завершена — переходим на экран результата
    ref.listen(gameProvider, (prev, next) {
      if (next.status == GameStatus.finished) {
        _handleGameFinished(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                GameHeader(gameState: gameState),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SchulteGrid(gameState: gameState),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(gameState),
                const SizedBox(height: 24),
              ],
            ),
            if (gameState.status == GameStatus.countdown)
              CountdownOverlay(value: gameState.countdownValue ?? 3),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(GameState gameState) {
    final found = gameState.nextNumber - 1;
    final total = gameState.totalNumbers;
    final progress = total > 0 ? found / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Найдено: $found / $total',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _handleGameFinished(GameState gameState) {
    final records = ref.read(recordsProvider.notifier);
    final isRecord = records.isPersonalRecord(
      gameState.gridSize,
      gameState.totalSeconds,
    );

    if (isRecord) {
      records.saveRecord(gameState.gridSize, gameState.totalSeconds);
    }

    final session = ref
        .read(gameProvider.notifier)
        .buildSession(isPersonalRecord: isRecord);

    ref.read(sessionsProvider.notifier).saveSession(session);

    context.go('/result', extra: {
      'session': session,
      'isRecord': isRecord,
    });
  }
}
```

---

## Хедер игры

### `lib/features/game/widgets/game_header.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';

class GameHeader extends ConsumerWidget {
  final GameState gameState;
  const GameHeader({super.key, required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Кнопка назад/пауза
          _PauseButton(gameState: gameState),
          const Spacer(),
          // Следующее число
          _NextNumberBadge(number: gameState.nextNumber),
          const Spacer(),
          // Таймер
          _TimerDisplay(seconds: gameState.totalSeconds),
        ],
      ),
    );
  }
}

class _PauseButton extends ConsumerWidget {
  final GameState gameState;
  const _PauseButton({required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (gameState.status == GameStatus.playing ||
            gameState.status == GameStatus.paused) {
          ref.read(gameProvider.notifier).togglePause();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          gameState.status == GameStatus.paused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _NextNumberBadge extends StatelessWidget {
  final int number;
  const _NextNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Найди',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  const _TimerDisplay({required this.seconds});

  String get _formatted {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '$s сек';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatted,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
```

---

## Сетка Шульте

### `lib/features/game/widgets/schulte_grid.dart`

Ключевой виджет. Сетка должна быть квадратной и занимать максимум пространства.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';

class SchulteGrid extends ConsumerWidget {
  final GameState gameState;
  const SchulteGrid({super.key, required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 1.0, // всегда квадрат
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gameState.gridSize,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: gameState.gridSize * gameState.gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ gameState.gridSize;
          final col = index % gameState.gridSize;
          final cell = gameState.grid.isNotEmpty
              ? gameState.grid[row][col]
              : null;

          return GridCell(
            cell: cell,
            gridSize: gameState.gridSize,
            onTap: gameState.status == GameStatus.playing
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(gameProvider.notifier).tapCell(row, col);
                  }
                : null,
          );
        },
      ),
    );
  }
}

class GridCell extends StatefulWidget {
  final GridCell? cell; // наша модель
  final int gridSize;
  final VoidCallback? onTap;

  const GridCell({
    super.key,
    required this.cell,
    required this.gridSize,
    this.onTap,
  });

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.cell?.isFound == true) return AppColors.success.withOpacity(0.2);
    if (widget.cell?.isError == true) return AppColors.error.withOpacity(0.3);
    return AppColors.surface;
  }

  Color get _borderColor {
    if (widget.cell?.isFound == true) return AppColors.success;
    if (widget.cell?.isError == true) return AppColors.error;
    return Colors.transparent;
  }

  Color get _textColor {
    if (widget.cell?.isFound == true) return AppColors.success;
    if (widget.cell?.isError == true) return AppColors.error;
    return AppColors.textPrimary;
  }

  double _fontSize() {
    if (widget.gridSize <= 4) return 24;
    if (widget.gridSize <= 5) return 20;
    if (widget.gridSize <= 6) return 17;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 2),
          ),
          child: Center(
            child: widget.cell?.isFound == true
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                  )
                : Text(
                    '${widget.cell?.number ?? ''}',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _fontSize(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

---

## Оверлей обратного отсчёта

### `lib/features/game/widgets/countdown_overlay.dart`

```dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class CountdownOverlay extends StatefulWidget {
  final int value;
  const CountdownOverlay({super.key, required this.value});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(CountdownOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.85),
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              '${widget.value}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 120,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Критерии готовности

- [ ] Игровой экран открывается с сеткой нужного размера
- [ ] Обратный отсчёт 3-2-1 с анимацией перед началом
- [ ] Правильный тап: клетка становится зелёной с галочкой
- [ ] Неправильный тап: красное мигание на 500ms
- [ ] Число «Найди» обновляется после каждого правильного тапа
- [ ] Таймер идёт во время игры, останавливается на паузе
- [ ] Прогресс-бар заполняется по мере нахождения чисел
- [ ] При нажатии последнего числа — переход на экран результата
- [ ] Haptic feedback на каждый тап
- [ ] Сетка квадратная на всех размерах экрана
