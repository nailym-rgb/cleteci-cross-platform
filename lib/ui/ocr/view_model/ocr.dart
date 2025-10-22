import 'dart:typed_data';

import 'package:aws_textract_api/textract-2018-06-27.dart';

class TextractService {
  final Textract _service;

  TextractService(this._service);

  Future<String> detectText(Uint8List imageBytes) async {
    try {
      final document = Document(bytes: imageBytes);
      final response = await _service.detectDocumentText(document: document);
      final extractedText = response.blocks
          ?.where((block) => block.blockType == BlockType.line)
          .map((block) => block.text)
          .join('\n');

      return extractedText ?? 'No text found';
    } catch (e) {
      throw Exception(e);
    }
  }

  void close() {
    _service.close();
  }
}
