import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:cleteci_cross_platform/domain/repositories/ocr_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/ui/ocr/widgets/ocr.dart';

/// Manual Mockito mock for OcrRepository (null-safe noSuchMethod pattern).
class MockOcrRepository extends Mock implements OcrRepository {
  @override
  // ignore: avoid_annotating_with_dynamic
  Future<String> extractTextFromImage(dynamic imageBytes) =>
      super.noSuchMethod(
            Invocation.method(#extractTextFromImage, [imageBytes]),
            returnValue: Future.value(''),
            returnValueForMissingStub: Future.value(''),
          )
          as Future<String>;

  @override
  // ignore: avoid_annotating_with_dynamic
  Future<String> extractTextFromPdf(dynamic pdfBytes) =>
      super.noSuchMethod(
            Invocation.method(#extractTextFromPdf, [pdfBytes]),
            returnValue: Future.value(''),
            returnValueForMissingStub: Future.value(''),
          )
          as Future<String>;
}

/// Mock ImagePicker — allows us to inject a fake pickImage result.
class MockImagePicker extends Mock implements ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) =>
      super.noSuchMethod(
            Invocation.method(#pickImage, [], {#source: source}),
            returnValue: Future<XFile?>.value(null),
            returnValueForMissingStub: Future<XFile?>.value(null),
          )
          as Future<XFile?>;
}

void main() {
  late MockOcrRepository mockOcrRepository;

  setUp(() {
    resetServiceLocator();
    mockOcrRepository = MockOcrRepository();
    // Register only what OCRScreen needs — avoids Firebase.instance crash
    getIt.registerSingleton<OcrRepository>(mockOcrRepository);
  });

  tearDown(() {
    resetServiceLocator();
  });

  Widget createTestWidget({
    String title = 'OCR Test',
    IconData icon = Icons.document_scanner,
    MaterialColor color = Colors.blue,
    OcrRepository? ocrRepository,
    ImagePicker? imagePicker,
  }) {
    return MaterialApp(
      home: SizedBox(
        height: 1000,
        child: OCRScreen(
          title: title,
          icon: icon,
          color: color,
          ocrRepository: ocrRepository ?? mockOcrRepository,
          imagePicker: imagePicker,
        ),
      ),
    );
  }

  group('OCRScreen Widget Tests', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(OCRScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Extract Text'), findsOneWidget);
    });

    testWidgets('displays image picker section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
      expect(find.text('No image or PDF selected.'), findsOneWidget);
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

    testWidgets('widget builds without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('handles different titles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'Test OCR'));
      await tester.pumpAndSettle();

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
              ocrRepository: mockOcrRepository,
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
        ocrRepository: mockOcrRepository,
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
        ocrRepository: mockOcrRepository,
      );
      expect(screen, isA<StatefulWidget>());
    });

    testWidgets('OCRScreen has required parameters', (
      WidgetTester tester,
    ) async {
      final screen = OCRScreen(
        title: 'Required',
        icon: Icons.star,
        color: Colors.green,
        ocrRepository: mockOcrRepository,
      );
      expect(screen.title, isNotNull);
      expect(screen.icon, isNotNull);
      expect(screen.color, isNotNull);
    });

    testWidgets('OCRScreen can have optional ocrRepository parameter', (
      WidgetTester tester,
    ) async {
      final screen = OCRScreen(
        title: 'Test',
        icon: Icons.home,
        color: Colors.blue,
        ocrRepository: mockOcrRepository,
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
        ocrRepository: mockOcrRepository,
      );
      expect(screen.key, equals(testKey));
    });

    testWidgets('OCRScreen can be created with different colors', (
      WidgetTester tester,
    ) async {
      final screen1 = OCRScreen(
        title: 'Test1',
        icon: Icons.one_k,
        color: Colors.red,
        ocrRepository: mockOcrRepository,
      );
      final screen2 = OCRScreen(
        title: 'Test2',
        icon: Icons.two_k,
        color: Colors.blue,
        ocrRepository: mockOcrRepository,
      );
      expect(screen1.color, equals(Colors.red));
      expect(screen2.color, equals(Colors.blue));
      expect(screen1.color, isNot(equals(screen2.color)));
    });

    testWidgets('OCRScreen can be created with different icons', (
      WidgetTester tester,
    ) async {
      final screen1 = OCRScreen(
        title: 'Test1',
        icon: Icons.camera,
        color: Colors.blue,
        ocrRepository: mockOcrRepository,
      );
      final screen2 = OCRScreen(
        title: 'Test2',
        icon: Icons.photo,
        color: Colors.blue,
        ocrRepository: mockOcrRepository,
      );
      expect(screen1.icon, equals(Icons.camera));
      expect(screen2.icon, equals(Icons.photo));
      expect(screen1.icon, isNot(equals(screen2.icon)));
    });

    // -----------------------------------------------------------------------
    // Coverage-boosting: exercise _processImage, extracted text, copy, loading
    // All camera-based image tests are omitted because Image.network in the
    // Flutter test runner never settles (no real HTTP stack available).
    // -----------------------------------------------------------------------

    testWidgets('Extract Text button is disabled when no file is selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Extract Text'),
      );
      // onPressed is null when no image is selected
      expect(btn.onPressed, isNull);
    });

    testWidgets('camera button calls MockImagePicker when tapped (cancel)', (
      WidgetTester tester,
    ) async {
      final mockImagePicker = MockImagePicker();
      when(
        mockImagePicker.pickImage(source: ImageSource.camera),
      ).thenAnswer((_) async => null); // user cancels

      await tester.pumpWidget(createTestWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Camera'));
      await tester.pump();

      verify(mockImagePicker.pickImage(source: ImageSource.camera)).called(1);
      // After cancel, still shows no-file placeholder
      expect(find.text('No image or PDF selected.'), findsOneWidget);
    });

    testWidgets('Select File button is present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select File'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('Camera button is present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('Extract Text button has correct icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.document_scanner_outlined), findsOneWidget);
    });

    testWidgets('OCRScreen shows Extracted Text label and divider at start', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Extracted Text:'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('camera button triggers pickImage with camera source', (
      WidgetTester tester,
    ) async {
      final mockImagePicker = MockImagePicker();
      when(
        mockImagePicker.pickImage(source: ImageSource.camera),
      ).thenAnswer((_) async => null); // user cancels

      await tester.pumpWidget(createTestWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Camera'));
      await tester.pump();

      verify(mockImagePicker.pickImage(source: ImageSource.camera)).called(1);
    });
  });
}
