import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';

void main() {
  group('Mode toggle logic', () {
    test('gorbov grid sizes are a subset of picker grid sizes', () {
      for (final size in AppConstants.gorbovGridSizes) {
        expect(AppConstants.pickerGridSizes.contains(size), isTrue,
            reason: 'Gorbov size $size should be in pickerGridSizes');
      }
    });

    test('gorbov mode requires minimum grid size 5', () {
      for (final size in AppConstants.gorbovGridSizes) {
        expect(size, greaterThanOrEqualTo(5));
      }
    });

    test('classic mode includes sizes below 5', () {
      final smallSizes = AppConstants.pickerGridSizes.where((s) => s < 5);
      expect(smallSizes, isNotEmpty);
    });

    test('all gorbov sizes are premium or available', () {
      // All gorbov sizes >= 5 — sizes 6, 7, 9 are premium, 5 is free
      expect(AppConstants.gorbovGridSizes.contains(5), isTrue);
      for (final size in [6, 7, 9]) {
        expect(AppConstants.premiumGridSizes.contains(size), isTrue);
      }
    });
  });
}
