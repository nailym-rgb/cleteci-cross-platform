import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:aws_textract_api/textract-2018-06-27.dart';

class TextractService {
  final String accessKey = dotenv.get('AWS_ACCESS_KEY');
  final String secretKey = dotenv.get('AWS_SECRET_KEY');
  final String awsRegion = dotenv.get('AWS_REGION');

  AwsClientCredentials get credentials =>
      AwsClientCredentials(accessKey: accessKey, secretKey: secretKey);

  Textract get service => Textract(region: awsRegion, credentials: credentials);

  Future<String> detectText(Uint8List imageBytes) async {
    try {
      final document = Document(bytes: imageBytes);
      final response = await service.detectDocumentText(document: document);
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
    service.close();
  }
}
