import 'dart:typed_data';

import 'package:aws_textract_api/textract-2018-06-27.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/repositories/ocr_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Manual Mockito mock for [Textract] using noSuchMethod null-safe pattern.
class MockTextract extends Mock implements Textract {
  @override
  void close() => super.noSuchMethod(
    Invocation.method(#close, []),
    returnValueForMissingStub: null,
  );

  @override
  Future<DetectDocumentTextResponse> detectDocumentText({
    required Document? document,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#detectDocumentText, [], {#document: document}),
            returnValue: Future<DetectDocumentTextResponse>.value(
              DetectDocumentTextResponse(),
            ),
            returnValueForMissingStub: Future<DetectDocumentTextResponse>.value(
              DetectDocumentTextResponse(),
            ),
          )
          as Future<DetectDocumentTextResponse>);
}

void main() {
  late MockTextract mockTextract;
  late OcrRepositoryImpl ocrRepository;
  late Uint8List fakeImageBytes;

  setUp(() {
    mockTextract = MockTextract();
    ocrRepository = OcrRepositoryImpl(textract: mockTextract);
    fakeImageBytes = Uint8List.fromList([1, 2, 3]);
  });

  group('OcrRepositoryImpl.extractTextFromImage', () {
    test(
      'extracts and joins LINE block text, ignores non-LINE blocks',
      () async {
        final mockResponse = DetectDocumentTextResponse(
          blocks: [
            Block(blockType: BlockType.line, text: 'Hello'),
            Block(blockType: BlockType.word, text: 'ignore'),
            Block(blockType: BlockType.line, text: 'World'),
          ],
        );

        when(
          mockTextract.detectDocumentText(document: anyNamed('document')),
        ).thenAnswer((_) async => mockResponse);

        final result = await ocrRepository.extractTextFromImage(fakeImageBytes);
        expect(result, 'Hello\nWorld');
      },
    );

    test('returns "No text found" when blocks is null', () async {
      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenAnswer((_) async => DetectDocumentTextResponse(blocks: null));

      final result = await ocrRepository.extractTextFromImage(fakeImageBytes);
      expect(result, 'No text found');
    });

    test('returns "No text found" when all blocks are non-LINE', () async {
      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenAnswer(
        (_) async => DetectDocumentTextResponse(
          blocks: [Block(blockType: BlockType.word, text: 'ignored')],
        ),
      );

      final result = await ocrRepository.extractTextFromImage(fakeImageBytes);
      expect(result, 'No text found');
    });

    test('throws Exception when Textract call throws', () async {
      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenThrow(Exception('AWS error'));

      await expectLater(
        () async => ocrRepository.extractTextFromImage(fakeImageBytes),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OcrRepositoryImpl.close', () {
    test('delegates close() to the Textract client', () {
      when(mockTextract.close()).thenAnswer((_) {});
      ocrRepository.close();
      verify(mockTextract.close()).called(1);
    });
  });
}
