import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up Firebase test mocks using the official platform interface mock.
/// This properly registers a mock platform so that [Firebase.initializeApp]
/// succeeds and [Firebase.apps] is populated in the test environment.
Future<void> setupFirebaseTestMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register the mock Firebase platform — this makes Firebase.initializeApp()
  // work in pure Dart tests without native platform channels.
  setupFirebaseCoreMocks();

  // Now Firebase.initializeApp will succeed because the mock platform is set.
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  } catch (e) {
    // Firebase might already be initialized from another test, ignore
  }
}
