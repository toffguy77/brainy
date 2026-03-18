import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/models/game_state.dart';

void main() {
  group('Gorbov grid generation', () {
    test('5x5 grid has 13 white and 12 red cells', () {
      final grid = generateGorbovGrid(5);
      final allCells = grid.expand((row) => row).toList();
      final whites = allCells.where((c) => c.color == 'white');
      final reds = allCells.where((c) => c.color == 'red');
      expect(whites.length, 13); // ceil(25/2)
      expect(reds.length, 12);  // floor(25/2)
    });

    test('7x7 grid has 25 white and 24 red cells', () {
      final grid = generateGorbovGrid(7);
      final allCells = grid.expand((row) => row).toList();
      final whites = allCells.where((c) => c.color == 'white');
      final reds = allCells.where((c) => c.color == 'red');
      expect(whites.length, 25);
      expect(reds.length, 24);
    });

    test('9x9 grid has 41 white and 40 red cells', () {
      final grid = generateGorbovGrid(9);
      final allCells = grid.expand((row) => row).toList();
      final whites = allCells.where((c) => c.color == 'white');
      final reds = allCells.where((c) => c.color == 'red');
      expect(whites.length, 41);
      expect(reds.length, 40);
    });

    test('white numbers are 1..whiteCount', () {
      final grid = generateGorbovGrid(5);
      final whites = grid.expand((r) => r).where((c) => c.color == 'white').toList();
      final numbers = whites.map((c) => c.number).toList()..sort();
      expect(numbers, List.generate(13, (i) => i + 1));
    });

    test('red numbers are 1..redCount', () {
      final grid = generateGorbovGrid(5);
      final reds = grid.expand((r) => r).where((c) => c.color == 'red').toList();
      final numbers = reds.map((c) => c.number).toList()..sort();
      expect(numbers, List.generate(12, (i) => i + 1));
    });

    test('all cells have valid row and col', () {
      final grid = generateGorbovGrid(5);
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          expect(grid[r][c].row, r);
          expect(grid[r][c].col, c);
        }
      }
    });

    test('no duplicate positions', () {
      final grid = generateGorbovGrid(7);
      final positions = <String>{};
      for (final row in grid) {
        for (final cell in row) {
          final key = '${cell.row},${cell.col}';
          expect(positions.contains(key), isFalse, reason: 'Duplicate position $key');
          positions.add(key);
        }
      }
      expect(positions.length, 49);
    });

    test('classic grid cells all have white color', () {
      final grid = generateClassicGrid(5);
      for (final row in grid) {
        for (final cell in row) {
          expect(cell.color, 'white');
        }
      }
    });
  });
}
