import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:cleteci_cross_platform/services/auth_service.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/auth_gate.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_page.dart';

// Mock class for AuthService
class MockAuthService extends Mock implements AuthService {
  @override
  FirebaseAuth get firebaseAuth => MockFirebaseAuth();

  @override
  Stream<User?> get authStateChanges => Stream.value(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late MockFirebaseAuth testAuth;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    testAuth = MockFirebaseAuth();
    mockAuthService = MockAuthService();

    // Reset and setup service locator
    resetServiceLocator();
    setupServiceLocatorForTesting(
      mockFirebaseAuth: mockAuth,
      mockAuthService: mockAuthService,
    );
  });

  tearDown(() => resetServiceLocator());

  Widget createTestWidget(MockFirebaseAuth auth) {
    return MaterialApp(
      home: AuthGate(auth: auth),
    );
  }

  Widget createTestWidgetWithDI() {
    return MaterialApp(
      home: const AuthGate(), // Uses service locator
    );
  }

  group('AuthGate Widget Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(mockAuth));

      // Assert - widget should render without crashing
      expect(find.byType(AuthGate), findsOneWidget);
    });

    testWidgets('should render with DI without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidgetWithDI());

      // Assert - widget should render without crashing
      expect(find.byType(AuthGate), findsOneWidget);
    });

    // testWidgets('should show test mode UI when using MockFirebaseAuth', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show test mode UI elements
    //   expect(find.byKey(const Key('email-field')), findsOneWidget);
    //   expect(find.byKey(const Key('password-field')), findsOneWidget);
    //   expect(find.byKey(const Key('sign-in-button')), findsOneWidget);
    //   expect(find.byKey(const Key('register-button')), findsOneWidget);
    //   expect(find.byKey(const Key('forgot-password-button')), findsOneWidget);
    //   expect(find.text('Welcome to Cleteci Cross Platform, please sign in!'), findsOneWidget);
    // });

    // testWidgets('should show production mode UI when using real FirebaseAuth', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(mockAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show production UI elements
    //   expect(find.byKey(const Key('sign-in-screen')), findsOneWidget);
    //   expect(find.byKey(const Key('auth-subtitle')), findsOneWidget);
    //   expect(find.text('Welcome to Cleteci Cross Platform, please sign in!'), findsOneWidget);
    // });

    // testWidgets('should show default page when user is authenticated', (WidgetTester tester) async {
    //   // Arrange
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockAuth = MockFirebaseAuth(mockUser: mockUser);

    //   // Act
    //   await tester.pumpWidget(createTestWidget(mockAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show default page
    //   expect(find.byType(DefaultPage), findsOneWidget);
    //   expect(find.text('Cleteci Cross Platform Homepage'), findsOneWidget);
    // });

    // testWidgets('should show auth UI when user is not authenticated', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(mockAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show auth UI
    //   expect(find.byKey(const Key('sign-in-screen')), findsOneWidget);
    //   expect(find.byType(DefaultPage), findsNothing);
    // });

    // testWidgets('should handle auth state changes', (WidgetTester tester) async {
    //   // Arrange
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockAuth = MockFirebaseAuth(mockUser: mockUser);

    //   // Act - start with authenticated user
    //   await tester.pumpWidget(createTestWidget(mockAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show default page
    //   expect(find.byType(DefaultPage), findsOneWidget);
    // });

    testWidgets('should show loading indicator during Firebase initialization', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(mockAuth));

      // Assert - should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // testWidgets('should show FutureBuilder and StreamBuilder', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(mockAuth));

    //   // Assert - should have FutureBuilder and StreamBuilder
    //   expect(find.byType(FutureBuilder), findsOneWidget);
    //   expect(find.byType(StreamBuilder), findsOneWidget);
    // });

    // testWidgets('should handle Firebase initialization completion', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(mockAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show auth UI after initialization
    //   expect(find.byType(CircularProgressIndicator), findsNothing);
    //   expect(find.byKey(const Key('sign-in-screen')), findsOneWidget);
    // });

    // testWidgets('should display logo in test mode', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show logo
    //   expect(find.bySemanticsLabel('Cleteci Logo'), findsOneWidget);
    // });

    // testWidgets('should display logo in production mode', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(mockAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should show logo
    //   expect(find.bySemanticsLabel('Cleteci Logo'), findsOneWidget);
    // });

    // testWidgets('should have proper semantics in test mode', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have proper semantic labels
    //   expect(find.bySemanticsLabel('email-input'), findsOneWidget);
    //   expect(find.bySemanticsLabel('password-input'), findsOneWidget);
    //   expect(find.bySemanticsLabel('sign-in-button'), findsOneWidget);
    //   expect(find.bySemanticsLabel('register-button'), findsOneWidget);
    //   expect(find.bySemanticsLabel('forgot-password-button'), findsOneWidget);
    // });

    // testWidgets('should handle sign in button tap in test mode', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Tap sign in button - this will call the method in the widget
    //   await tester.tap(find.byKey(const Key('sign-in-button')));
    //   await tester.pump();

    //   // Assert - button tap should be handled without crashing
    //   expect(find.byType(AuthGate), findsOneWidget);
    // });

    testWidgets('should have constrained box with max width', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(testAuth));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - should have constrained box
      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    // testWidgets('should have proper padding', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have padding widgets
    //   expect(find.byType(Padding), findsWidgets);
    // });

    // testWidgets('should have proper text field properties in test mode', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - email field should have email keyboard type
    //   final emailField = tester.widget<TextField>(find.byKey(const Key('email-field')));
    //   expect(emailField.keyboardType, TextInputType.emailAddress);

    //   // Password field should be obscured
    //   final passwordField = tester.widget<TextField>(find.byKey(const Key('password-field')));
    //   expect(passwordField.obscureText, isTrue);
    // });

    // testWidgets('should have proper button styling', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have elevated button and text buttons
    //   expect(find.byType(ElevatedButton), findsOneWidget);
    //   expect(find.byType(TextButton), findsNWidgets(2)); // Register and forgot password
    // });

    // testWidgets('should have proper aspect ratio for logo', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have aspect ratio widget
    //   expect(find.byType(AspectRatio), findsOneWidget);
    // });

    // testWidgets('should have proper column layout', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have column layout
    //   expect(find.byType(Column), findsWidgets);
    // });

    // testWidgets('should have proper sized boxes for spacing', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have sized boxes for spacing
    //   expect(find.byType(SizedBox), findsWidgets);
    // });

    testWidgets('should have center alignment', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(testAuth));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - should have center widget
      expect(find.byType(Center), findsWidgets);
    });

    // testWidgets('should have scaffold structure', (WidgetTester tester) async {
    //   // Act
    //   await tester.pumpWidget(createTestWidget(testAuth));
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();
    //   await tester.pump();

    //   // Assert - should have scaffold
    //   expect(find.byType(Scaffold), findsOneWidget);
    // });

    testWidgets('should handle future builder states', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(mockAuth));

      // Assert - should handle future builder loading state
      expect(find.byType(FutureBuilder), findsOneWidget);
    });
  });
}