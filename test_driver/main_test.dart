import 'package:flutter_driver/driver_extension.dart';
import 'package:cleteci_cross_platform/main_test.dart' as app;

void main() {
  // Enable Flutter Driver extension
  enableFlutterDriverExtension();

  // Call the app's main function
  app.main();
}