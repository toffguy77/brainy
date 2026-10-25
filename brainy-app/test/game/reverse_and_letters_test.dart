import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/models/game_state.dart';

List<GridCell> _flat(List<List<GridCell>> grid) =>
    grid.expand((row) => row).toList();

void main() {
  group('reverse mode', () {
    test('taps run from N² down to 1', () {
      final grid = generateReverseGrid(4);
      final cells = _flat(grid);
      // Ordinal 1 is the first tap and must show the highest value.
      expect(cells.firstWhere((c) => c.number == 1).display, '16');
      // The last tap shows 1.
      expect(cells.firstWhere((c) => c.number == 16).display, '1');
    });

    test('every ordinal 1..N² appears exactly once', () {
      final cells = _flat(generateReverseGrid(5));
      final ordinals = cells.map((c) => c.number).toList()..sort();
      expect(ordinals, List.generate(25, (i) => i + 1));
    });

    test('displayed values are exactly 1..N²', () {
      final cells = _flat(generateReverseGrid(3));
      final shown = cells.map((c) => int.parse(c.display)).toList()..sort();
      expect(shown, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('ordinal and displayed value are mirror images', () {
      const size = 5;
      for (final cell in _flat(generateReverseGrid(size))) {
        expect(int.parse(cell.display), size * size - cell.number + 1);
      }
    });

    test('positions are randomised across generations', () {
      final a = _flat(generateReverseGrid(5)).map((c) => c.number).toList();
      final b = _flat(generateReverseGrid(5)).map((c) => c.number).toList();
      expect(a, isNot(equals(b)));
    });

    test('is available at every grid size', () {
      expect(AppConstants.gridSizesForMode('reverse'),
          containsAll(AppConstants.allGridSizes));
    });
  });

  group('letters mode', () {
    test('a 3x3 English grid contains exactly A through I', () {
      final shown = _flat(generateLettersGrid(3, 'en')).map((c) => c.display).toList()
        ..sort();
      expect(shown, ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']);
    });

    test('a 3x3 Russian grid starts the alphabet at А', () {
      final cells = _flat(generateLettersGrid(3, 'ru'));
      expect(cells.firstWhere((c) => c.number == 1).display, 'А');
      expect(cells.firstWhere((c) => c.number == 2).display, 'Б');
    });

    test('every letter on the grid is distinct', () {
      final shown = _flat(generateLettersGrid(5, 'ru')).map((c) => c.display);
      expect(shown.toSet().length, 25);
    });

    test('the grid is a contiguous prefix, not a random sample', () {
      final alphabet = AppConstants.alphabetFor('en');
      final shown = _flat(generateLettersGrid(4, 'en')).map((c) => c.display).toSet();
      expect(shown, alphabet.take(16).toSet());
    });

    test('ordinal matches alphabet position', () {
      final alphabet = AppConstants.alphabetFor('ru');
      for (final cell in _flat(generateLettersGrid(4, 'ru'))) {
        expect(cell.display, alphabet[cell.number - 1]);
      }
    });

    test('positions are randomised while the letter set is fixed', () {
      final a = _flat(generateLettersGrid(4, 'en')).map((c) => c.display).toList();
      final b = _flat(generateLettersGrid(4, 'en')).map((c) => c.display).toList();
      expect(a, isNot(equals(b)));
      expect(a.toSet(), b.toSet());
    });

    test('only 3, 4 and 5 are offered', () {
      expect(AppConstants.gridSizesForMode('letters'), [3, 4, 5]);
    });

    test('availability does not depend on the active locale', () {
      // The bound uses the shortest supported alphabet, so a language switch
      // must not change which sizes are playable.
      for (final size in AppConstants.gridSizesForMode('letters')) {
        expect(() => generateLettersGrid(size, 'ru'), returnsNormally);
        expect(() => generateLettersGrid(size, 'en'), returnsNormally);
      }
    });

    test('a size beyond the alphabet is rejected rather than malformed', () {
      expect(() => generateLettersGrid(6, 'en'), throwsArgumentError);
      expect(() => generateLettersGrid(9, 'ru'), throwsArgumentError);
    });

    test('ambiguous Russian letters are excluded', () {
      // «Ё»/«Е» and «Й»/«И» differ by a few pixels at grid size.
      expect(AppConstants.alphabetRu, isNot(contains('Ё')));
      expect(AppConstants.alphabetRu, isNot(contains('Й')));
      expect(AppConstants.alphabetRu, contains('Е'));
      expect(AppConstants.alphabetRu, contains('И'));
    });

    test('both alphabets are long enough for the largest offered grid', () {
      final maxCells = AppConstants.gridSizesForMode('letters')
          .map((s) => s * s)
          .reduce((a, b) => a > b ? a : b);
      expect(AppConstants.alphabetRu.length, greaterThanOrEqualTo(maxCells));
      expect(AppConstants.alphabetEn.length, greaterThanOrEqualTo(maxCells));
    });

    test('alphabets contain no duplicates', () {
      expect(AppConstants.alphabetRu.toSet().length,
          AppConstants.alphabetRu.length);
      expect(AppConstants.alphabetEn.toSet().length,
          AppConstants.alphabetEn.length);
    });
  });

  group('grid size clamping on mode switch', () {
    test('classic 9x9 clamps into range when switching to letters', () {
      expect(AppConstants.clampGridSizeForMode('letters', 9), 5);
    });

    test('3x3 clamps up when switching to gorbov', () {
      expect(AppConstants.clampGridSizeForMode('gorbov', 3), 5);
    });

    test('a valid size is left alone', () {
      expect(AppConstants.clampGridSizeForMode('letters', 4), 4);
      expect(AppConstants.clampGridSizeForMode('classic', 9), 9);
    });

    test('every mode clamps every size to something it offers', () {
      for (final mode in ['classic', 'reverse', 'gorbov', 'letters']) {
        for (final size in AppConstants.allGridSizes) {
          final clamped = AppConstants.clampGridSizeForMode(mode, size);
          expect(AppConstants.gridSizesForMode(mode), contains(clamped),
              reason: '$mode/$size clamped to $clamped');
        }
      }
    });
  });
}
