import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  DeviceIdService._();

  static const _storageKey = 'brainy_device_id';
  static const _storage = FlutterSecureStorage();
  static String? _cachedId;

  static Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    // Try reading from Keychain first
    try {
      final stored = await _storage.read(key: _storageKey);
      if (stored != null && stored.isNotEmpty) {
        _cachedId = stored;
        return stored;
      }
    } catch (e) {
      debugPrint('[DeviceIdService] Error reading from secure storage: $e');
    }

    // Try platform device ID
    String? platformId;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        platformId = iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        platformId = androidInfo.id;
      }
    } catch (e) {
      debugPrint('[DeviceIdService] Error getting platform device ID: $e');
    }

    // Fallback to UUID v4
    final id = platformId ?? const Uuid().v4();
    _cachedId = id;

    // Persist to Keychain
    try {
      await _storage.write(key: _storageKey, value: id);
    } catch (e) {
      debugPrint('[DeviceIdService] Error writing to secure storage: $e');
    }

    return id;
  }
}
