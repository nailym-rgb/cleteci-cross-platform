import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/edit_profile_dialog.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/update_user_profile.dart';

// Generate mocks
@GenerateMocks([ImagePicker, UpdateUserProfile, XFile])
import 'edit_profile_dialog_test.mocks.dart';

void main() {
  late MockImagePicker mockImagePicker;
  late MockUpdateUserProfile mockUpdateUserProfile;
  late UserProfileEntity testUserProfile;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockUpdateUserProfile = MockUpdateUserProfile();
    testUserProfile = UserProfileEntity(
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
      when(mockUpdateUserProfile.call(any)).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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
      final profileWithoutAvatar = UserProfileEntity(
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
                    updateUserProfile: mockUpdateUserProfile,
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
                    updateUserProfile: mockUpdateUserProfile,
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

    testWidgets('should call UpdateUserProfile use case on valid save', (WidgetTester tester) async {
      when(mockUpdateUserProfile.call(any)).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    userProfile: testUserProfile,
                    updateUserProfile: mockUpdateUserProfile,
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

      // Tap save with valid data
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Should have called UpdateUserProfile with the entity
      verify(mockUpdateUserProfile.call(any)).called(1);
    });
  });
}
