// Stub implementation for non-web platforms.
// Returns empty/nullable defaults so native code can continue using pdf_render.

Future<List<String>> renderPdfPages(String base64Pdf) async {
  return <String>[];
}

Future<String?> renderPdfFirstPagePreview(String base64Pdf) async {
  return null;
}

Future<List<String>> ocrPdfPages(String base64Pdf, int maxPages) async {
  return <String>[];
}

Future<String> ocrDataUrl(String dataUrl) async {
  return '';
}
