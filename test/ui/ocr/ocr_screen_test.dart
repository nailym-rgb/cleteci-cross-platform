import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/ui/ocr/widgets/ocr.dart';
import 'package:cleteci_cross_platform/ui/ocr/view_model/ocr.dart';

// Mock classes
class MockTextractService extends Mock implements TextractService {}

void main() {
  late MockTextractService mockTextractService;

  setUp(() {
    mockTextractService = MockTextractService();
  });

  Widget createTestWidget({
    String title = 'OCR Test',
    IconData icon = Icons.document_scanner,
    MaterialColor color = Colors.blue,
    TextractService? textractService,
    String Function(String, {String? fallback})? envGetter,
  }) {
    return MaterialApp(
      home: SizedBox(
        height: 1000, // Give enough height for scrolling
        child: OCRScreen(
          title: title,
          icon: icon,
          color: color,
          textractService: textractService ?? mockTextractService,
          envGetter: envGetter ?? (key, {fallback}) {
            // Provide valid AWS credentials for tests
            if (key == 'AZ_ACCESS_KEY') return 'test-access-key';
            if (key == 'AZ_SECRET_KEY') return 'test-secret-key';
            if (key == 'AZ_REGION') return 'us-east-1';
            return fallback ?? '';
          },
        ),
      ),
    );
  }

  group('OCRScreen Widget Tests', () {
    testWidgets('renders correctly with valid credentials', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are rendered
      expect(find.byType(OCRScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Extract Text'), findsOneWidget);
    });

    testWidgets('displays image picker section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify image picker components exist
      expect(find.byType(Container), findsWidgets);
      expect(find.text('No image selected.'), findsOneWidget);
    });

    testWidgets('displays extract text button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Extract Text'), findsOneWidget);
    });

    testWidgets('displays results section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Extracted Text:'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('shows AWS configuration warning when credentials are missing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        envGetter: (key, {fallback}) => '', // Return empty strings for all env vars
      ));
      await tester.pumpAndSettle();

      // Should show the AWS configuration warning screen
      expect(find.text('Configuración de AWS incompleta'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Volver'), findsOneWidget);
    });

    testWidgets('widget builds without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify no exceptions were thrown during build
      expect(tester.takeException(), isNull);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify layout components
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('handles different titles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'Test OCR'));
      await tester.pumpAndSettle();

      // The title is passed but not displayed in the UI
      expect(find.byType(OCRScreen), findsOneWidget);
    });

    testWidgets('handles different screen sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 800,
            width: 400,
            child: OCRScreen(
              title: 'OCR Test',
              icon: Icons.document_scanner,
              color: Colors.blue,
              textractService: mockTextractService,
              envGetter: (key, {fallback}) {
                if (key == 'AZ_ACCESS_KEY') return 'test-access-key';
                if (key == 'AZ_SECRET_KEY') return 'test-secret-key';
                if (key == 'AZ_REGION') return 'us-east-1';
                return fallback ?? '';
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OCRScreen), findsOneWidget);
    });

    testWidgets('OCRScreen constructor works', (WidgetTester tester) async {
      final screen = OCRScreen(
        title: 'Test OCR',
        icon: Icons.document_scanner,
        color: Colors.blue,
        textractService: mockTextractService,
        envGetter: (key, {fallback}) => 'test-value',
      );
      expect(screen, isNotNull);
      expect(screen, isA<OCRScreen>());
      expect(screen.title, equals('Test OCR'));
      expect(screen.icon, equals(Icons.document_scanner));
      expect(screen.color, equals(Colors.blue));
    });

    testWidgets('OCRScreen is a StatefulWidget', (WidgetTester tester) async {
      final screen = OCRScreen(
        title: 'Test',
        icon: Icons.camera,
        color: Colors.red,
      );
      expect(screen, isA<StatefulWidget>());
    });

    testWidgets('OCRScreen has required parameters', (WidgetTester tester) async {
      // This would fail to compile if title, icon, or color were not required
      final screen = OCRScreen(
        title: 'Required',
        icon: Icons.star,
        color: Colors.green,
      );
      expect(screen.title, isNotNull);
      expect(screen.icon, isNotNull);
      expect(screen.color, isNotNull);
    });

    testWidgets('OCRScreen can have optional parameters', (WidgetTester tester) async {
      final screen = OCRScreen(
        title: 'Test',
        icon: Icons.home,
        color: Colors.blue,
        textractService: mockTextractService,
        envGetter: (key, {fallback}) => 'optional',
      );
      expect(screen, isNotNull);
    });

    testWidgets('OCRScreen has key parameter', (WidgetTester tester) async {
      const testKey = Key('ocr_screen_key');
      final screen = OCRScreen(
        key: testKey,
        title: 'Test',
        icon: Icons.settings,
        color: Colors.purple,
      );
      expect(screen.key, equals(testKey));
    });

    testWidgets('OCRScreen can be created with different colors', (WidgetTester tester) async {
      final screen1 = OCRScreen(
        title: 'Test1',
        icon: Icons.one_k,
        color: Colors.red,
      );
      final screen2 = OCRScreen(
        title: 'Test2',
        icon: Icons.two_k,
        color: Colors.blue,
      );
      expect(screen1.color, equals(Colors.red));
      expect(screen2.color, equals(Colors.blue));
      expect(screen1.color, isNot(equals(screen2.color)));
    });

    testWidgets('OCRScreen can be created with different icons', (WidgetTester tester) async {
      final screen1 = OCRScreen(
        title: 'Test1',
        icon: Icons.camera,
        color: Colors.blue,
      );
      final screen2 = OCRScreen(
        title: 'Test2',
        icon: Icons.photo,
        color: Colors.blue,
      );
      expect(screen1.icon, equals(Icons.camera));
      expect(screen2.icon, equals(Icons.photo));
      expect(screen1.icon, isNot(equals(screen2.icon)));
    });
  });
}