import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/game/providers/records_provider.dart';

void main() {
  group('Records key format', () {
    test('recordKey builds correct format', () {
      expect(recordKey('classic', 5), 'classic_5');
      expect(recordKey('gorbov', 7), 'gorbov_7');
    });

    test('isLegacyKey detects old-format keys', () {
      expect(isLegacyKey('5'), isTrue);
      expect(isLegacyKey('9'), isTrue);
      expect(isLegacyKey('classic_5'), isFalse);
      expect(isLegacyKey('gorbov_7'), isFalse);
    });
  });
}
