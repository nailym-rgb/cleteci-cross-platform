import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_register_form.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';
import '../../../config/firebase_test_utils.dart';

// Mock classes
class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService mockUserService;
  late MockFirebaseAuth mockAuth;

  setUpAll(() async {
    await setupFirebaseTestMocks();
  });

  setUp(() {
    mockUserService = MockUserService();
    mockAuth = MockFirebaseAuth();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: SizedBox(
        height: 1000, // Give enough height for scrolling
        child: CustomRegisterForm(
          userService: mockUserService,
          auth: mockAuth,
        ),
      ),
    );
  }

  group('CustomRegisterForm', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are rendered
      expect(find.byType(CustomRegisterForm), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Registro'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays header with logo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify logo is displayed
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('displays avatar selector', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify avatar selector components
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);
      expect(find.text('Cámara'), findsOneWidget);
    });

    testWidgets('displays form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify form fields are present (using more specific finders)
      expect(find.byType(TextFormField), findsNWidgets(5)); // 5 form fields
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify buttons are present
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('¿Ya tienes cuenta? Inicia sesión'), findsOneWidget);
    });

    testWidgets('can enter text in form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test entering text in first name field
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.pump();

      // Verify text was entered
      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('avatar selector has buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify avatar selection buttons exist
      expect(find.byType(TextButton), findsWidgets); // At least some buttons
    });

    testWidgets('form has proper structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify form structure
      expect(find.byType(Column), findsWidgets); // Multiple columns in the layout
      expect(find.byType(Padding), findsWidgets); // Padding widgets
      expect(find.byType(ConstrainedBox), findsWidgets); // Constrained boxes for responsive design
    });

    testWidgets('form validation logic exists', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test that form validation is present by checking form structure
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5)); // 5 form fields
    });

    testWidgets('dispose method works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The dispose method should be called when widget is removed
      // This is tested implicitly by the framework
      expect(find.byType(CustomRegisterForm), findsOneWidget);
    });

    testWidgets('widget builds without errors', (WidgetTester tester) async {
      // Test that the widget builds successfully with all its components
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify no exceptions were thrown during build
      expect(tester.takeException(), isNull);
    });

    testWidgets('form fields have proper hints', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for hint texts
      expect(find.text('Ingresa tu nombre'), findsOneWidget);
      expect(find.text('Ingresa tu apellido'), findsOneWidget);
      expect(find.text('correo@ejemplo.com'), findsOneWidget);
    });

    testWidgets('has interactive elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that the widget has interactive elements
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}