import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes,
        [Map<String, Object?>? args]) async {
      // This callback runs on the HOST machine, not in the simulator.
      // The screenshot name from binding.takeScreenshot() arrives here.
      final file = File('screenshots/$name.png');
      file.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}
