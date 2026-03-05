import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aws_textract_api/textract-2018-06-27.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf_render_plus/pdf_render.dart';

import '../../../domain/repositories/ocr_repository.dart';
import '../../../ui/ocr/pdf_renderer.dart';

/// Infrastructure implementation of [OcrRepository].
///
/// On native platforms, both image and PDF extraction use AWS Textract.
/// On web, PDF extraction uses client-side Tesseract.js (via JS interop in
/// [pdf_renderer.dart]). Image extraction is the same on all platforms.
///
/// AWS credentials are read from `dotenv` inside this class — they never
/// leak into the domain layer or the UI.
class OcrRepositoryImpl implements OcrRepository {
  final Textract _textract;

  /// Constructor with optional [textract] injection for testing.
  OcrRepositoryImpl({Textract? textract})
    : _textract = textract ?? _createTextract();

  static Textract _createTextract() {
    final accessKey = dotenv.get('AZ_ACCESS_KEY', fallback: '');
    final secretKey = dotenv.get('AZ_SECRET_KEY', fallback: '');
    final region = dotenv.get('AZ_REGION', fallback: 'us-east-1');
    final credentials = AwsClientCredentials(
      accessKey: accessKey,
      secretKey: secretKey,
    );
    return Textract(region: region, credentials: credentials);
  }

  @override
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    try {
      final document = Document(bytes: imageBytes);
      final response = await _textract.detectDocumentText(document: document);
      final extractedText = response.blocks
          ?.where((block) => block.blockType == BlockType.line)
          .map((block) => block.text)
          .join('\n');
      if (extractedText == null || extractedText.isEmpty) {
        return 'No text found';
      }
      return extractedText;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<String> extractTextFromPdf(Uint8List pdfBytes) async {
    if (kIsWeb) {
      return _extractTextFromPdfWeb(pdfBytes);
    } else {
      return _extractTextFromPdfNative(pdfBytes);
    }
  }

  Future<String> _extractTextFromPdfWeb(Uint8List pdfBytes) async {
    // On web: use the pdf.js helper to render pages, then Tesseract.js for OCR.
    // Maximum 5 pages to avoid browser timeout.
    const int maxPages = 5;
    final buffer = StringBuffer();

    try {
      // Render all PDF pages via pdf.js
      final base64Pdf = _uint8ListToBase64(pdfBytes);
      final pages = await renderPdfPages(base64Pdf);

      if (pages.isEmpty) {
        return 'No text found';
      }

      final pagesToProcess = pages.length > maxPages ? maxPages : pages.length;

      for (int i = 0; i < pagesToProcess; i++) {
        final dataUrl = pages[i];
        final text = await ocrDataUrl(dataUrl);
        if (text.isNotEmpty) {
          buffer.writeln('--- Página ${i + 1} ---');
          buffer.writeln(text);
        }
      }
    } catch (e) {
      throw Exception('Error processing PDF on web: $e');
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? 'No text found' : result;
  }

  Future<String> _extractTextFromPdfNative(Uint8List pdfBytes) async {
    final buffer = StringBuffer();
    final dynamic doc = await PdfDocument.openData(pdfBytes);

    try {
      for (int i = 1; i <= doc.pageCount; i++) {
        final dynamic page = await doc.getPage(i);

        // Scale 2.5× for better OCR accuracy
        const double scale = 2.5;
        final int renderWidth = (page.width * scale).toInt();
        final int renderHeight = (page.height * scale).toInt();

        final dynamic pageImage = await page.render(
          width: renderWidth,
          height: renderHeight,
          backgroundFill: true,
        );

        Uint8List? pageBytes;
        try {
          // Convert raw pixels via dart:ui for maximum compatibility
          final Completer<ui.Image> completer = Completer();
          ui.decodeImageFromPixels(
            pageImage.pixels,
            pageImage.width,
            pageImage.height,
            ui.PixelFormat.rgba8888,
            completer.complete,
          );
          final ui.Image uiImage = await completer.future;
          final byteData = await uiImage.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (byteData != null) {
            pageBytes = byteData.buffer.asUint8List();
          }
          uiImage.dispose();
        } catch (_) {
          // Pixel conversion failed — mark page as unprocessable below
        }

        try {
          pageImage.dispose();
          page.dispose();
        } catch (_) {}

        if (pageBytes != null) {
          final result = await extractTextFromImage(pageBytes);
          if (result.isNotEmpty) {
            buffer.writeln('--- Página $i ---');
            buffer.writeln(result);
          } else {
            buffer.writeln('--- Página $i (Sin texto detectado) ---');
          }
        } else {
          buffer.writeln('--- Página $i ---');
          buffer.writeln('Error: No se pudo procesar la imagen de la página.');
        }
      }
    } finally {
      try {
        doc.dispose();
      } catch (_) {}
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? 'No text found' : result;
  }

  /// Closes the underlying AWS Textract client and releases resources.
  void close() {
    _textract.close();
  }

  static String _uint8ListToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
