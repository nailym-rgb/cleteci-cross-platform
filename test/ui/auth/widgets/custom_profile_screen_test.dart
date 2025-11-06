import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cleteci_cross_platform/config/theme_provider.dart';
import 'package:cleteci_cross_platform/models/user_profile.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_profile_screen.dart';
import '../../../config/firebase_test_utils.dart';

class MockUserService extends Mock implements UserService {
  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    return UserProfile(
      uid: 'test-uid',
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) async {
    // Mock implementation
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    // Mock implementation
  }
}

void main() {
  late MockUserService mockUserService;
  late MockFirebaseAuth mockAuth;
  late ThemeProvider themeProvider;

  setUpAll(() async {
    await setupFirebaseTestMocks();
  });

  setUp(() {
    mockUserService = MockUserService();
    mockAuth = MockFirebaseAuth();
    themeProvider = ThemeProvider();
  });

  tearDown(() {
    // Reset any static state if needed
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => themeProvider,
      child: MaterialApp(
        home: CustomUserProfileScreen(userService: mockUserService, auth: mockAuth),
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
  });
}