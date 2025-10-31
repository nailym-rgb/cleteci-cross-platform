import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_register_form.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockUserService extends Mock implements UserService {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserService mockUserService;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserService = MockUserService();
    mockImagePicker = MockImagePicker();
  });

  group('CustomRegisterForm', () {
    testWidgets('should render all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Check for logo
      expect(find.byType(AspectRatio), findsOneWidget);

      // Check for form fields
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Apellido'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);

      // Check for buttons
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('¿Ya tienes cuenta? Inicia sesión'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Tap register button without filling fields
      await tester.tap(find.text('Registrarse'));
      await tester.pump();

      // Check for validation errors
      expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
      expect(find.text('Por favor ingresa tu apellido'), findsOneWidget);
      expect(find.text('Por favor ingresa tu correo electrónico'), findsOneWidget);
      expect(find.text('Por favor ingresa una contraseña'), findsOneWidget);
      expect(find.text('Por favor confirma tu contraseña'), findsOneWidget);
    });

    testWidgets('should show error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Fill form with invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingresa tu nombre'), 'John');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingresa tu apellido'), 'Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'correo@ejemplo.com'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar contraseña'), 'password123');

      await tester.tap(find.text('Registrarse'));
      await tester.pump();

      expect(find.text('Por favor ingresa un correo electrónico válido'), findsOneWidget);
    });

    testWidgets('should show error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Fill form with short password
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingresa tu nombre'), 'John');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingresa tu apellido'), 'Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'correo@ejemplo.com'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), '123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar contraseña'), '123');

      await tester.tap(find.text('Registrarse'));
      await tester.pump();

      expect(find.text('La contraseña debe tener al menos 6 caracteres'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Fill form with mismatched passwords
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingresa tu nombre'), 'John');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingresa tu apellido'), 'Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'correo@ejemplo.com'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar contraseña'), 'password456');

      await tester.tap(find.text('Registrarse'));
      await tester.pump();

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('should show avatar picker buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Check for avatar picker buttons
      expect(find.text('Galería'), findsOneWidget);
      expect(find.text('Cámara'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      expect(find.text('Registro'), findsOneWidget);
    });

    testWidgets('should have proper form structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Check for form widget
      expect(find.byType(Form), findsOneWidget);

      // Check for SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Check for Column layout
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have proper button styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Check for ElevatedButton with icon
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);

      // Check for TextButton
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should have responsive layout with LayoutBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(),
          ),
        ),
      );

      // Check for LayoutBuilder
      expect(find.byType(LayoutBuilder), findsOneWidget);

      // Check for ConstrainedBox
      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });
}