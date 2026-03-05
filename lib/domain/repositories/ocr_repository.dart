import 'dart:typed_data';

/// Interfaz de repositorio para operaciones de OCR
/// Define el contrato para extracción de texto de documentos sin dependencias de implementación
abstract class OcrRepository {
  /// Extraer texto de una imagen
  Future<String> extractTextFromImage(Uint8List imageBytes);

  /// Extraer texto de un PDF completo
  Future<String> extractTextFromPdf(Uint8List pdfBytes);
}