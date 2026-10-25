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

    test('every gorbov size is playable without any unlock', () {
      expect(AppConstants.gorbovGridSizes, isNotEmpty);
      for (final size in AppConstants.gorbovGridSizes) {
        expect(AppConstants.allGridSizes, contains(size));
      }
    });
  });
}
