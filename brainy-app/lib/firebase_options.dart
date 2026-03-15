import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBm2_xE8RfQQSq9SQw2uB9_hEVLuhOxpLc',
    appId: '1:745886476435:ios:06af413bf6495121be4566',
    messagingSenderId: '745886476435',
    projectId: 'brainy-app-1e48c',
    storageBucket: 'brainy-app-1e48c.firebasestorage.app',
    iosBundleId: 'com.brainyapp.brainy',
  );
}
