import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/speech_service.dart';
import '../ui/auth/view_model/local_auth_state.dart';

/// Service locator for dependency injection
/// Uses get_it for managing dependencies across the app
final GetIt getIt = GetIt.instance;

/// Setup service locator with all dependencies
Future<void> setupServiceLocator() async {
  // Register Firebase Auth
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Register Auth Service
  getIt.registerSingleton<AuthService>(
    AuthService(getIt<FirebaseAuth>()),
  );

  // Register Speech Service
  getIt.registerSingleton<SpeechService>(SpeechService());

  // Register Local Auth State
  getIt.registerSingleton<LocalAuthState>(LocalAuthState());
}

/// Reset service locator (useful for testing)
void resetServiceLocator() {
  getIt.reset();
}

/// Setup service locator for testing with mocks
void setupServiceLocatorForTesting({
  FirebaseAuth? mockFirebaseAuth,
  AuthService? mockAuthService,
  SpeechService? mockSpeechService,
  LocalAuthState? mockLocalAuthState,
}) {
  // Register Firebase Auth (mock or real)
  getIt.registerSingleton<FirebaseAuth>(
    mockFirebaseAuth ?? FirebaseAuth.instance,
  );

  // Register Auth Service (mock or real)
  getIt.registerSingleton<AuthService>(
    mockAuthService ?? AuthService(getIt<FirebaseAuth>()),
  );

  // Register Speech Service (mock or real)
  getIt.registerSingleton<SpeechService>(
    mockSpeechService ?? SpeechService(),
  );

  // Register Local Auth State (mock or real)
  getIt.registerSingleton<LocalAuthState>(
    mockLocalAuthState ?? LocalAuthState(),
  );
}