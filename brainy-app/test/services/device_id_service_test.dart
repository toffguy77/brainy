import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/shared/services/device_id_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceIdService', () {
    test('getDeviceId returns non-empty string', () async {
      // In test env, plugins fail, so UUID fallback is used
      final id = await DeviceIdService.getDeviceId();
      expect(id, isNotEmpty);
    });

    test('getDeviceId returns same value on consecutive calls (caching)',
        () async {
      final id1 = await DeviceIdService.getDeviceId();
      final id2 = await DeviceIdService.getDeviceId();
      expect(id1, equals(id2));
    });

    test('device ID has valid UUID v4 format when using fallback', () async {
      final id = await DeviceIdService.getDeviceId();
      // UUID v4 format: 8-4-4-4-12 hex chars
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(id, matches(uuidRegex));
    });

    test('device ID length is 36 characters (standard UUID)', () async {
      final id = await DeviceIdService.getDeviceId();
      expect(id.length, 36);
    });

    test('multiple rapid calls all return identical value', () async {
      final futures = List.generate(10, (_) => DeviceIdService.getDeviceId());
      final results = await Future.wait(futures);
      for (final result in results) {
        expect(result, equals(results.first));
      }
    });
  });
}
