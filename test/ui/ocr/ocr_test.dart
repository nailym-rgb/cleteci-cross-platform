import 'dart:typed_data';

import 'package:aws_textract_api/textract-2018-06-27.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/repositories/ocr_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ocr_test.mocks.dart';

@GenerateMocks([Textract])
void main() {
  late MockTextract mockTextract;
  late OcrRepositoryImpl ocrRepository;
  late Uint8List fakeImageBytes;

  setUp(() {
    mockTextract = MockTextract();
    ocrRepository = OcrRepositoryImpl(textract: mockTextract);
    fakeImageBytes = Uint8List(0);
  });

  group('OcrRepositoryImpl.extractTextFromImage', () {
    test('extracts and joins LINE block text', () async {
      final mockBlock1 = Block(blockType: BlockType.line, text: 'Hello');
      final mockBlock2 = Block(blockType: BlockType.word, text: 'ignore this');
      final mockBlock3 = Block(blockType: BlockType.line, text: 'World');
      final mockResponse = DetectDocumentTextResponse(
        blocks: [mockBlock1, mockBlock2, mockBlock3],
      );

      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenAnswer((_) async => mockResponse);

      final result = await ocrRepository.extractTextFromImage(fakeImageBytes);
      expect(result, 'Hello\nWorld');
      verify(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).called(1);
    });

    test('returns "No text found" when blocks list is null', () async {
      final mockResponse = DetectDocumentTextResponse(blocks: null);

      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenAnswer((_) async => mockResponse);

      final result = await ocrRepository.extractTextFromImage(fakeImageBytes);
      expect(result, 'No text found');
    });

    test('returns "No text found" when blocks list is empty', () async {
      final mockResponse = DetectDocumentTextResponse(blocks: []);

      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenAnswer((_) async => mockResponse);

      final result = await ocrRepository.extractTextFromImage(fakeImageBytes);
      expect(result, 'No text found');
    });

    test('throws Exception when Textract call fails', () async {
      when(
        mockTextract.detectDocumentText(document: anyNamed('document')),
      ).thenThrow(Exception('AWS 404 Error'));

      expect(
        () => ocrRepository.extractTextFromImage(fakeImageBytes),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OcrRepositoryImpl.close', () {
    test('calls close on the underlying Textract client', () {
      when(mockTextract.close()).thenAnswer((_) {});
      ocrRepository.close();
      verify(mockTextract.close()).called(1);
    });
  });
}
