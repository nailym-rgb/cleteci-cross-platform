import 'dart:typed_data';

import 'package:cleteci_cross_platform/ui/ocr/view_model/ocr.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:aws_textract_api/textract-2018-06-27.dart';

import 'ocr_test.mocks.dart';

@GenerateMocks([Textract])
void main() {
  late MockTextract mockTextract;
  late TextractService textractService;
  late Uint8List fakeImageBytes;

  setUp(() {
    // Initialize the mocks and the service before each test
    mockTextract = MockTextract();
    // Inject the mock client into the service
    textractService = TextractService(mockTextract);
    fakeImageBytes = Uint8List(0);
  });

  group('TextractService Tests', () {
    test(
      'detectText successfully extracts and joins text from LINE blocks',
      () async {
        final mockBlock1 = Block(blockType: BlockType.line, text: 'Hello');
        final mockBlock2 = Block(
          blockType: BlockType.word,
          text: 'ignore this',
        );
        final mockBlock3 = Block(blockType: BlockType.line, text: 'World');
        final mockResponse = DetectDocumentTextResponse(
          blocks: [mockBlock1, mockBlock2, mockBlock3],
        );

        when(
          mockTextract.detectDocumentText(document: anyNamed('document')),
        ).thenAnswer((_) async => mockResponse);
        final result = await textractService.detectText(fakeImageBytes);
        expect(result, 'Hello\nWorld');
        verify(
          mockTextract.detectDocumentText(document: anyNamed('document')),
        ).called(1);
      },
    );

    test(
      'detectText returns "No text found" when blocks list is null',
      () async {
        final mockResponse = DetectDocumentTextResponse(blocks: null);

        when(
          mockTextract.detectDocumentText(document: anyNamed('document')),
        ).thenAnswer((_) async => mockResponse);
        final result = await textractService.detectText(fakeImageBytes);
        expect(result, 'No text found');
      },
    );

    test(
      'detectText throws an Exception when the service call fails',
      () async {
        final awsError = Exception('AWS 404 Error');

        when(
          mockTextract.detectDocumentText(document: anyNamed('document')),
        ).thenThrow(awsError);
        final call = textractService.detectText;
        expect(() => call(fakeImageBytes), throwsA(isA<Exception>()));
      },
    );

    test('close() calls close() on the service', () {
      when(mockTextract.close()).thenAnswer((_) {});
      textractService.close();
      verify(mockTextract.close()).called(1);
    });
  });
}
