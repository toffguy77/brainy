import 'package:flutter/material.dart';
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
      aspectRatio: 1.0,
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
          final cell =
              gameState.grid.isNotEmpty ? gameState.grid[row][col] : null;

          return GridCellWidget(
            cell: cell,
            gridSize: gameState.gridSize,
            onTap: gameState.status == GameStatus.playing
                ? () {
                    ref.read(gameProvider.notifier).tapCell(row, col);
                  }
                : null,
          );
        },
      ),
    );
  }
}

class GridCellWidget extends StatefulWidget {
  final GridCell? cell;
  final int gridSize;
  final VoidCallback? onTap;

  const GridCellWidget({
    super.key,
    required this.cell,
    required this.gridSize,
    this.onTap,
  });

  @override
  State<GridCellWidget> createState() => _GridCellWidgetState();
}

class _GridCellWidgetState extends State<GridCellWidget>
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
    if (widget.cell?.isFound == true) {
      return AppColors.success.withValues(alpha: 0.2);
    }
    if (widget.cell?.isError == true) {
      return AppColors.error.withValues(alpha: 0.3);
    }
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
