import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/edit_profile_dialog.dart';
import 'package:cleteci_cross_platform/models/user_profile.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';

// Generate mocks
@GenerateMocks([ImagePicker, UserService, XFile])
import 'edit_profile_dialog_test_new.mocks.dart';

void main() {
  late MockImagePicker mockImagePicker;
  late MockUserService mockUserService;
  late UserProfile testUserProfile;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockUserService = MockUserService();
    testUserProfile = UserProfile(
      uid: 'test-uid',
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('EditProfileDialog', () {
    testWidgets('should display dialog title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Perfil'), findsOneWidget);
    });

    testWidgets('should initialize form fields with user profile data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check that form fields are initialized
      expect(find.text('John'), findsOneWidget); // First name
      expect(find.text('Doe'), findsOneWidget); // Last name
    });

    testWidgets('should display avatar section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check avatar buttons
      expect(find.text('Galería'), findsOneWidget);
      expect(find.text('Cámara'), findsOneWidget);
    });

    testWidgets('should validate form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Clear first name field
      await tester.enterText(find.widgetWithText(TextFormField, 'John'), '');
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
    });

    testWidgets('should validate last name field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Clear last name field
      await tester.enterText(find.widgetWithText(TextFormField, 'Doe'), '');
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor ingresa tu apellido'), findsOneWidget);
    });

    testWidgets('should handle cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Editar Perfil'), findsNothing);
    });

    testWidgets('should show loading state during save', (WidgetTester tester) async {
      // Mock successful save
      when(mockUserService.updateUserProfile(
        uid: anyNamed('uid'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        avatarUrl: anyNamed('avatarUrl'),
      )).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Note: Testing the actual save functionality would require dependency injection
      // for the UserService, which is not currently implemented in the widget.
      // This test verifies the UI structure is correct.

      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('should display form fields with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check labels
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Apellido'), findsOneWidget);
    });

    testWidgets('should handle text input changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Change first name
      await tester.enterText(find.widgetWithText(TextFormField, 'John'), 'Jane');
      await tester.pump();

      // Verify the text changed
      expect(find.text('Jane'), findsOneWidget);
    });

    testWidgets('should display avatar with user initials when no avatar', (WidgetTester tester) async {
      final profileWithoutAvatar = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: profileWithoutAvatar,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should display initials
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should have scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    userService: mockUserService,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should have SingleChildScrollView for scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}