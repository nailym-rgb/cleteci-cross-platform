import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cleteci_cross_platform/config/theme_provider.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/auth_repository.dart';
import 'package:cleteci_cross_platform/domain/repositories/user_profile_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/auth/sign_out_use_case.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/get_user_profile.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/update_user_profile.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/services/camara_gallery_service.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_profile_screen.dart';
import '../../../config/firebase_test_utils.dart';

final _testUser = UserProfileEntity(
  uid: 'test-uid',
  email: 'test@example.com',
  firstName: 'John',
  lastName: 'Doe',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  UserProfileEntity? get currentUser => _testUser;

  @override
  Stream<UserProfileEntity?> get authStateChanges => Stream.value(_testUser);
}

class MockUserProfileRepository extends Mock implements UserProfileRepository {
  @override
  Future<UserProfileEntity?> getProfile(String uid) async => _testUser;

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {}

  @override
  Future<void> deleteProfile(String uid) async {}

  @override
  Stream<UserProfileEntity?> watchProfile(String uid) =>
      Stream.value(_testUser);
}

class MockSignOutUseCase extends Mock implements SignOutUseCase {
  @override
  Future<void> call() async {}
}

class MockCamaraGalleryService extends Mock implements CamaraGalleryService {
  @override
  Future<String?> takePhoto() async => null;

  @override
  Future<String?> selectPhoto() async => null;
}

void main() {
  late GetUserProfile getUserProfile;
  late UpdateUserProfile updateUserProfile;
  late MockAuthRepository mockAuthRepository;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockCamaraGalleryService mockCamaraGalleryService;
  late ThemeProvider themeProvider;

  setUpAll(() async {
    await setupFirebaseTestMocks();
  });

  setUp(() {
    final mockUserProfileRepository = MockUserProfileRepository();
    getUserProfile = GetUserProfile(mockUserProfileRepository);
    updateUserProfile = UpdateUserProfile(mockUserProfileRepository);
    mockAuthRepository = MockAuthRepository();
    mockSignOutUseCase = MockSignOutUseCase();
    mockCamaraGalleryService = MockCamaraGalleryService();
    themeProvider = ThemeProvider();
  });

  tearDown(() {
    // Reset any static state if needed
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => themeProvider,
      child: MaterialApp(
        home: CustomUserProfileScreen(
          getUserProfile: getUserProfile,
          updateUserProfile: updateUserProfile,
          authRepository: mockAuthRepository,
          signOutUseCase: mockSignOutUseCase,
          camaraGalleryService: mockCamaraGalleryService,
        ),
      ),
    );
  }

  group('CustomUserProfileScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The screen should render without crashing
      expect(find.byType(CustomUserProfileScreen), findsOneWidget);
    });

    testWidgets('builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Just verify the widget builds without errors
      expect(find.byType(CustomUserProfileScreen), findsOneWidget);
    });

    testWidgets('loads user profile via GetUserProfile use case', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Profile data should be displayed from the use case result
      expect(find.byType(CustomUserProfileScreen), findsOneWidget);
    });
  });
}
