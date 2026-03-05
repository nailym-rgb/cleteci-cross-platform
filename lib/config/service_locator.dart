import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/ocr_repository.dart';
import '../domain/repositories/speech_repository.dart';
import '../domain/repositories/user_profile_repository.dart';
import '../domain/usecases/auth/sign_in_use_case.dart';
import '../domain/usecases/auth/sign_out_use_case.dart';
import '../domain/usecases/user_profile/get_user_profile.dart';
import '../domain/usecases/user_profile/update_user_profile.dart';
import '../shared/infrastructure/repositories/auth_repository_impl.dart';
import '../shared/infrastructure/repositories/firebase_user_profile_repository_impl.dart';
import '../shared/infrastructure/repositories/ocr_repository_impl.dart';
import '../shared/infrastructure/repositories/speech_repository_impl.dart';
import '../shared/infrastructure/services/camara_gallery_service.dart';
import '../shared/infrastructure/services/camara_gallery_service_impl.dart';
import '../ui/auth/view_model/local_auth_state.dart';

/// Service locator for dependency injection
/// Uses get_it for managing dependencies across the app
final GetIt getIt = GetIt.instance;

/// Setup service locator with all dependencies
Future<void> setupServiceLocator() async {
  // Register Firebase Auth
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Register Firebase Firestore
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Register Speech Repository (interface → implementation)
  getIt.registerSingleton<SpeechRepository>(SpeechRepositoryImpl());

  // Register Local Auth State
  getIt.registerSingleton<LocalAuthState>(LocalAuthState());

  // Register CamaraGalleryService (interface → implementation)
  getIt.registerSingleton<CamaraGalleryService>(CamaraGalleryServiceImpl());

  // Register OCR Repository (interface → implementation)
  getIt.registerSingleton<OcrRepository>(OcrRepositoryImpl());

  // Register domain repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<FirebaseAuth>()),
  );

  getIt.registerSingleton<UserProfileRepository>(
    FirebaseUserProfileRepositoryImpl(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
    ),
  );

  // Register domain use cases
  getIt.registerFactory<SignInUseCase>(
    () => SignInUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<GetUserProfile>(
    () => GetUserProfile(getIt<UserProfileRepository>()),
  );

  getIt.registerFactory<UpdateUserProfile>(
    () => UpdateUserProfile(getIt<UserProfileRepository>()),
  );
}

/// Reset service locator (useful for testing)
void resetServiceLocator() {
  getIt.reset();
}

/// Setup service locator for testing with mocks
void setupServiceLocatorForTesting({
  FirebaseAuth? mockFirebaseAuth,
  FirebaseFirestore? mockFirebaseFirestore,
  SpeechRepository? mockSpeechRepository,
  LocalAuthState? mockLocalAuthState,
  AuthRepository? mockAuthRepository,
  UserProfileRepository? mockUserProfileRepository,
  CamaraGalleryService? mockCamaraGalleryService,
  OcrRepository? mockOcrRepository,
}) {
  // Register Firebase Auth (mock or real)
  getIt.registerSingleton<FirebaseAuth>(
    mockFirebaseAuth ?? FirebaseAuth.instance,
  );

  // Register Firebase Firestore (mock or real)
  getIt.registerSingleton<FirebaseFirestore>(
    mockFirebaseFirestore ?? FirebaseFirestore.instance,
  );

  // Register Speech Repository (mock or real)
  getIt.registerSingleton<SpeechRepository>(
    mockSpeechRepository ?? SpeechRepositoryImpl(),
  );

  // Register Local Auth State (mock or real)
  getIt.registerSingleton<LocalAuthState>(
    mockLocalAuthState ?? LocalAuthState(),
  );

  // Register CamaraGalleryService (mock or real)
  getIt.registerSingleton<CamaraGalleryService>(
    mockCamaraGalleryService ?? CamaraGalleryServiceImpl(),
  );

  // Register OCR Repository (mock or real)
  getIt.registerSingleton<OcrRepository>(
    mockOcrRepository ?? OcrRepositoryImpl(),
  );

  // Register domain repositories (mock or real)
  getIt.registerSingleton<AuthRepository>(
    mockAuthRepository ?? AuthRepositoryImpl(getIt<FirebaseAuth>()),
  );

  getIt.registerSingleton<UserProfileRepository>(
    mockUserProfileRepository ??
        FirebaseUserProfileRepositoryImpl(
          getIt<FirebaseFirestore>(),
          getIt<FirebaseAuth>(),
        ),
  );

  // Register domain use cases
  getIt.registerFactory<SignInUseCase>(
    () => SignInUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<GetUserProfile>(
    () => GetUserProfile(getIt<UserProfileRepository>()),
  );

  getIt.registerFactory<UpdateUserProfile>(
    () => UpdateUserProfile(getIt<UserProfileRepository>()),
  );
}
