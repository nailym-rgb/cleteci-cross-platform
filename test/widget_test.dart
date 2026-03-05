// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:cleteci_cross_platform/app.dart';
import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:cleteci_cross_platform/domain/repositories/ocr_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock FirebaseFirestore to avoid calling FirebaseFirestore.instance
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Mock OcrRepository to avoid dotenv initialization in test
class MockOcrRepository extends Mock implements OcrRepository {
  @override
  Future<String> extractTextFromImage(Uint8List imageBytes) =>
      super.noSuchMethod(
            Invocation.method(#extractTextFromImage, [imageBytes]),
            returnValue: Future.value(''),
            returnValueForMissingStub: Future.value(''),
          )
          as Future<String>;

  @override
  Future<String> extractTextFromPdf(Uint8List pdfBytes) =>
      super.noSuchMethod(
            Invocation.method(#extractTextFromPdf, [pdfBytes]),
            returnValue: Future.value(''),
            returnValueForMissingStub: Future.value(''),
          )
          as Future<String>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset service locator before each test
    resetServiceLocator();
    // Setup service locator for testing with mock auth and firestore
    setupServiceLocatorForTesting(
      mockFirebaseAuth: MockFirebaseAuth(),
      mockFirebaseFirestore: MockFirebaseFirestore(),
      mockOcrRepository: MockOcrRepository(),
    );
  });

  tearDown(() => resetServiceLocator());

  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(auth: MockFirebaseAuth()));

    // Pump multiple times to handle async initialization
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify that the app loads without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
