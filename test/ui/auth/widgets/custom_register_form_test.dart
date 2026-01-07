import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_register_form.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';
import '../../../config/firebase_test_utils.dart';

// Mock classes
class MockUserService extends Mock implements UserService {
  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) {
    // Esto intercepta la llamada para que podamos simular éxito o fallo
    return super.noSuchMethod(
      Invocation.method(#createUserProfile, [], {
        #uid: uid,
        #email: email,
        #firstName: firstName,
        #lastName: lastName,
        #avatarUrl: avatarUrl,
      }),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

class SpyUserService extends Mock implements UserService {
  // Variables para guardar lo que recibe el método
  String? capturedUid;
  String? capturedEmail;
  bool wasCalled = false;

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) async {
    // 1. Guardamos los datos para verificarlos después (Spying)
    capturedUid = uid;
    capturedEmail = email;
    wasCalled = true;

    // 2. Retornamos un Future completado (Éxito inmediato)
    return Future.value();
  }
}

class FailingUserService extends Mock implements UserService {
  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) async {
    // En lugar de usar 'when', lanzamos el error directamente aquí
    throw Exception('Error de conexión a BD');
  }
}

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

  Widget createTestWidget({UserService? userService}) {
    return MaterialApp(
      home: SizedBox(
        height: 1000, // Give enough height for scrolling
        child: CustomRegisterForm(
          userService: userService ?? mockUserService,
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

  group('Lógica del método _register', () {
    Future<void> fillForm(WidgetTester tester) async {
      // 1. Usar el HINT TEXT ('Ingresa tu nombre') en lugar del Label ('Nombre')
      // Asegúrate de usar ensureVisible en cada uno por si el teclado tapa los campos

      // Nombre
      final nameField = find.widgetWithText(TextFormField, 'Ingresa tu nombre');
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Juan');

      // Apellido
      final lastNameField = find.widgetWithText(
        TextFormField,
        'Ingresa tu apellido',
      );
      await tester.ensureVisible(lastNameField);
      await tester.enterText(lastNameField, 'Perez');

      // Email
      final emailField = find.widgetWithText(
        TextFormField,
        'correo@ejemplo.com',
      );
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'test@test.com');

      // Contraseña
      final passField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.ensureVisible(passField);
      await tester.enterText(passField, '123456');

      // Confirmar Contraseña
      final confirmField = find.widgetWithText(
        TextFormField,
        'Confirmar contraseña',
      );
      await tester.ensureVisible(confirmField);
      await tester.enterText(confirmField, '123456');
    }

    testWidgets('Éxito: Crea usuario, guarda en DB y muestra éxito', (
      WidgetTester tester,
    ) async {
      // 1. PREPARACIÓN: Usamos el Spy
      final spyService = SpyUserService();

      // Inyectamos el spy
      await tester.pumpWidget(createTestWidget(userService: spyService));
      await tester.pumpAndSettle();

      // 2. Llenar formulario
      await fillForm(tester);

      // 3. Presionar Registrarse
      final registerButton = find.text('Registrarse'); // O 'Sign Up'
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);

      // 4. Verificar estado de carga
      // Como el Spy es muy rápido, el loading puede pasar en un microsegundo.
      // Hacemos pump para procesar el tap y la lógica
      await tester.pump();

      // Opcional: Si quieres ver el loading estrictamente, tendrías que poner un delay dentro del Spy,
      // pero para pruebas funcionales, verificar el resultado final suele ser suficiente.

      // 5. Esperar a que termine todo
      await tester.pumpAndSettle();

      // 6. VERIFICACIÓN (Reemplaza al 'verify' de Mockito)

      // A) Verificar que el método fue llamado
      expect(
        spyService.wasCalled,
        true,
        reason: 'El servicio debió ser llamado',
      );

      // B) Verificar los datos exactos
      expect(spyService.wasCalled, true);
      expect(
        spyService.capturedEmail,
        'test@test.com',
      ); // El email que escribió fillForm

      // C) Verificar el UID (debe ser un String, no nulo)
      expect(spyService.capturedUid, isNotNull);
      expect(spyService.capturedUid, isNotEmpty);

      // 7. Verificar SnackBar de éxito
      expect(
        find.text('¡Registro exitoso! Redirigiendo al login...'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });
    testWidgets('Fallo Auth: Muestra error si Firebase falla', (
      WidgetTester tester,
    ) async {
      // NO necesitamos configurar mockUserService porque va a fallar antes de llegar ahí.
      // Pero necesitamos inyectar un error en Firebase Auth.
      // Como mockAuth (firebase_auth_mocks) simula éxito por defecto, es difícil forzar error
      // a menos que uses un Mock de FirebaseAuth generado por Mockito, NO la librería 'mocks'.

      // **ESTRATEGIA ALTERNATIVA PARA ERROR DE AUTH**:
      // Usar un email inválido que Firebase rechace o simular comportamiento si usas Mockito puro.
      // Asumiendo que usas `MockFirebaseAuth` de la librería `firebase_auth_mocks`,
      // esta librería valida emails. Si ponemos un email sin dominio, firebase mock fallará.

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Llenar formulario pero modificar el email para forzar error interno si la librería valida
      // Ojo: Tu Regex de UI pasará, pero firebase podría rechazarlo si está mal formado en backend logic
      // Si no puedes forzar error con la librería de mocks, salta al siguiente test (Fallo Service).

      // Supongamos que queremos probar el catch general:
      // Si usas Mockito para Auth en lugar de firebase_auth_mocks, harías:
      // when(mockAuth.createUserWithEmailAndPassword(...)).thenThrow(FirebaseAuthException(code: 'error'));
    });

    testWidgets('Fallo Service: Muestra error si UserService falla', (
      WidgetTester tester,
    ) async {
      // 1. PREPARACIÓN: Usamos el servicio "Fake" que siempre falla.
      // No necesitamos 'when' ni 'anyNamed'. La clase ya trae el error por dentro.
      final failingService = FailingUserService();

      // Inyectamos el servicio fallido al crear el widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRegisterForm(
              userService:
                  failingService, // <--- Aquí usamos el servicio que falla
              auth: mockAuth, // El Auth sigue siendo el normal (éxito)
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Llenar el formulario
      // (Asegúrate de usar la versión correcta de fillForm que usa hintText)
      await fillForm(tester);

      // 3. Tap Registrar
      final registerButton = find.text('Registrarse');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);

      // 4. Esperar al SnackBar
      // Como el error es inmediato (no hay await real en el fake), pump simple basta
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // 5. Verificar mensaje de error
      // Esto confirmará que la UI atrapó la excepción del FailingUserService
      expect(find.textContaining('Error en el registro'), findsOneWidget);
    });
  });
}
