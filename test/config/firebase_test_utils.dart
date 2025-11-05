import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up Firebase test mocks
Future<void> setupFirebaseTestMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase initialization
  await Firebase.initializeApp(
    name: 'test',
    options: const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project-id',
    ),
  );
}