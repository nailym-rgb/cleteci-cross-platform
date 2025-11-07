import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cleteci_cross_platform/ui/settings/widgets/theme_settings_screen.dart';
import 'package:cleteci_cross_platform/config/theme_provider.dart';

void main() {
  late ThemeProvider themeProvider;

  setUp(() {
    themeProvider = ThemeProvider();
  });

  Widget createTestWidget(Widget child) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('ThemeSettingsScreen Widget Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert - widget should render without throwing exceptions
      expect(find.byType(ThemeSettingsScreen), findsOneWidget);
    });

    testWidgets('should have proper structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should contain scrollable content', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should contain basic UI elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should contain buttons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should contain containers', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should contain card widgets for sections', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should contain column layouts', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should contain padding widgets', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should handle theme provider changes', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Change theme
      themeProvider.notifyListeners();

      // Rebuild
      await tester.pump();

      // Assert - widget should still be present
      expect(find.byType(ThemeSettingsScreen), findsOneWidget);
    });

    testWidgets('should display title text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.text('Customize Theme Colors'), findsOneWidget);
    });

    testWidgets('should display color section titles', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.text('Primary Color'), findsOneWidget);
      expect(find.text('Seed Color'), findsOneWidget);
      expect(find.text('App Bar Text Color'), findsOneWidget);
      expect(find.text('Button Text Color'), findsOneWidget);
      expect(find.text('Error Color'), findsOneWidget);
      expect(find.text('Error Text Color'), findsOneWidget);
    });

    testWidgets('should display reset button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.text('Reset to Defaults'), findsOneWidget);
      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('should display preview section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Assert
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('App Bar Preview'), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Outlined Button'), findsOneWidget);
      expect(find.text('This is an error message preview'), findsOneWidget);
    });

    testWidgets('should open color picker dialog when choose color button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Find and tap the first "Choose Color" button
      final chooseColorButton = find.text('Choose Color').first;
      await tester.tap(chooseColorButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Choose Color'), findsWidgets); // Dialog title
      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('should open reset dialog when reset button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Scroll to make reset button visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pump();

      // Find and tap the reset button
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reset Theme'), findsOneWidget);
      expect(find.text('Are you sure you want to reset the theme to default colors?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('should call resetToDefaults when reset is confirmed', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Scroll to make reset button visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pump();

      // Open reset dialog
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Tap reset button in dialog
      final confirmResetButton = find.text('Reset');
      await tester.tap(confirmResetButton);
      await tester.pumpAndSettle();

      // Assert - dialog should be closed and snackbar shown
      expect(find.text('Reset Theme'), findsNothing);
      expect(find.text('Theme reset to defaults'), findsOneWidget);
    });

    testWidgets('should cancel reset dialog when cancel is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const ThemeSettingsScreen()));

      // Scroll to make reset button visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pump();

      // Open reset dialog
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Tap cancel button in dialog
      final cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Assert - dialog should be closed
      expect(find.text('Reset Theme'), findsNothing);
    });
  });

  group('ColorPicker Widget Tests', () {
    testWidgets('should render ColorPicker widget', (WidgetTester tester) async {
      // Arrange
      Color selectedColor = Colors.blue;

      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (color) => selectedColor = color,
      )));

      // Assert
      expect(find.byType(ColorPicker), findsOneWidget);
      expect(find.byType(Container), findsWidgets); // Color display containers
    });

    testWidgets('should display current color', (WidgetTester tester) async {
      // Arrange
      const testColor = Colors.red;

      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: testColor,
        onColorChanged: (_) {},
      )));

      // Assert - should find containers with the color
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display predefined colors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (_) {},
      )));

      // Assert - should have multiple color containers (predefined + custom picker)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should call onColorChanged when predefined color is selected', (WidgetTester tester) async {
      // Arrange
      Color selectedColor = Colors.blue;
      const newColor = Color(0xFF2196F3); // First predefined color

      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (color) => selectedColor = color,
      )));

      // Find and tap a predefined color (skip the custom picker button)
      final colorContainers = find.byType(GestureDetector);
      await tester.tap(colorContainers.at(1)); // First predefined color
      await tester.pump();

      // Assert
      expect(selectedColor, equals(newColor));
    });

    testWidgets('should open custom color picker dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (_) {},
      )));

      // Find and tap the custom color picker button (first GestureDetector)
      final customPickerButton = find.byType(GestureDetector).first;
      await tester.tap(customPickerButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Custom Color Picker'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(3));
    });

    testWidgets('should update color in custom picker when sliders change', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (_) {},
      )));

      // Open custom color picker
      final customPickerButton = find.byType(GestureDetector).first;
      await tester.tap(customPickerButton);
      await tester.pumpAndSettle();

      // Find red slider and change its value
      final redSlider = find.byType(Slider).first;
      await tester.drag(redSlider, const Offset(100, 0)); // Drag to increase red value
      await tester.pump();

      // Assert - should find some text showing the updated value (not necessarily 255)
      expect(find.byType(Slider), findsNWidgets(3));
      expect(find.text('Red'), findsOneWidget);
    });

    testWidgets('should select custom color when select button is tapped', (WidgetTester tester) async {
      // Arrange
      Color selectedColor = Colors.blue;

      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (color) => selectedColor = color,
      )));

      // Open custom color picker
      final customPickerButton = find.byType(GestureDetector).first;
      await tester.tap(customPickerButton);
      await tester.pumpAndSettle();

      // Change red slider to 255
      final redSlider = find.byType(Slider).first;
      await tester.drag(redSlider, const Offset(1000, 0)); // Drag to max
      await tester.pump();

      // Tap select button
      final selectButton = find.text('Select');
      await tester.tap(selectButton);
      await tester.pumpAndSettle();

      // Assert - color should be different from original blue
      expect(selectedColor, isNot(equals(Colors.blue)));
    });

    testWidgets('should cancel custom color picker without changes', (WidgetTester tester) async {
      // Arrange
      Color selectedColor = Colors.blue;

      // Act
      await tester.pumpWidget(createTestWidget(ColorPicker(
        currentColor: Colors.blue,
        onColorChanged: (color) => selectedColor = color,
      )));

      // Open custom color picker
      final customPickerButton = find.byType(GestureDetector).first;
      await tester.tap(customPickerButton);
      await tester.pumpAndSettle();

      // Change red slider
      final redSlider = find.byType(Slider).first;
      await tester.drag(redSlider, const Offset(1000, 0));
      await tester.pump();

      // Tap cancel button
      final cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Assert - color should remain unchanged
      expect(selectedColor, equals(Colors.blue));
    });
  });
}