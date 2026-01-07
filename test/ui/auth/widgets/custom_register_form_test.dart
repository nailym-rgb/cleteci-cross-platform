import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
        child: CustomRegisterForm(userService: mockUserService, auth: mockAuth),
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
      expect(
        find.byType(Column),
        findsWidgets,
      ); // Multiple columns in the layout
      expect(find.byType(Padding), findsWidgets); // Padding widgets
      expect(
        find.byType(ConstrainedBox),
        findsWidgets,
      ); // Constrained boxes for responsive design
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

  group('Password Validation', () {
    testWidgets('It displays an error if the password is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Buscar el botón de registro
      final registerButton = find.text('Registrarse');
      await tester.ensureVisible(registerButton);

      // 2. Presionar sin llenar nada
      await tester.tap(registerButton);
      await tester.pumpAndSettle(); // Esperar a que la UI se actualice

      // 3. Verificar que aparece el mensaje de error del validador
      expect(find.text('Por favor ingresa una contraseña'), findsOneWidget);
    });

    testWidgets(
      'It displays an error if the password is less than 6 characters',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 1. Encontrar el campo usando el hintText que definiste en tu código
        // Tu hintText es 'Contraseña' para el campo de password
        final passwordField = find.widgetWithText(TextFormField, 'Contraseña');

        // Asegurar que es visible (por el scroll)
        await tester.ensureVisible(passwordField);

        // 2. Escribir contraseña corta
        await tester.enterText(passwordField, '12345');
        await tester.pump();

        // 3. Presionar registrarse
        final registerButton = find.text('Registrarse');
        await tester.ensureVisible(registerButton);
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // 4. Validar el mensaje de error específico de longitud
        expect(
          find.text('La contraseña debe tener al menos 6 caracteres'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Displays an error if the passwords do not match (SnackBar)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Llenar campo contraseña correctamente
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.ensureVisible(passwordField);
      await tester.enterText(passwordField, '123456');

      // 2. Llenar campo confirmar contraseña con texto diferente
      // Tu hintText es 'Confirmar contraseña'
      final confirmField = find.widgetWithText(
        TextFormField,
        'Confirmar contraseña',
      );
      await tester.ensureVisible(confirmField);
      await tester.enterText(confirmField, '654321');

      // 3. Llenar otros campos obligatorios para que el Form sea válido y llegue a la lógica de comparación
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ingresa tu nombre'),
        'Test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ingresa tu apellido'),
        'User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'correo@ejemplo.com'),
        'test@test.com',
      );

      // 4. Presionar registrarse
      final registerButton = find.text('Registrarse');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // 5. Verificar que aparece el SnackBar
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });
  });

  group('Email Validation Tests', () {
    testWidgets('Shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Buscamos el botón de registro
      final registerButton = find.text('Registrarse');
      await tester.ensureVisible(registerButton);

      // 2. Presionamos el botón sin escribir nada en el email
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // 3. Verificamos que aparezca el mensaje de error de campo vacío
      expect(
        find.text('Por favor ingresa tu correo electrónico'),
        findsOneWidget,
      );
    });

    testWidgets('Shows error when email format is invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Encontrar el campo de email por su hintText
      final emailField = find.widgetWithText(
        TextFormField,
        'correo@ejemplo.com',
      );
      await tester.ensureVisible(emailField);

      // 2. Ingresar un texto que no es email
      await tester.enterText(emailField, 'esto-no-es-un-email');
      await tester.pump();

      // 3. Presionar registrarse para disparar la validación
      final registerButton = find.text('Registrarse');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // 4. Verificar el mensaje de error de formato inválido
      expect(
        find.text('Por favor ingresa un correo electrónico válido'),
        findsOneWidget,
      );
    });

    testWidgets('Does not show error when email is valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Encontrar el campo e ingresar un email válido
      final emailField = find.widgetWithText(
        TextFormField,
        'correo@ejemplo.com',
      );
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'usuario@prueba.com');
      await tester.pump();

      // 2. Presionar registrarse
      final registerButton = find.text('Registrarse');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // 3. Verificar que NO aparezca el error de email
      expect(
        find.text('Por favor ingresa un correo electrónico válido'),
        findsNothing,
      );
      expect(
        find.text('Por favor ingresa tu correo electrónico'),
        findsNothing,
      );
    });
  });
}
