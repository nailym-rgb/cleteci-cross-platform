// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:js_util' as js_util;
import 'dart:html' as html;

/// Calls the `renderPdfPages(base64Pdf)` helper exposed in `web/index.html`.
Future<List<String>> renderPdfPages(String base64Pdf) async {
  final future = js_util.callMethod(html.window, 'renderPdfPages', [base64Pdf]);
  final pages = await js_util.promiseToFuture(future) as List<dynamic>;
  return pages.map((p) => p as String).toList();
}

Future<String?> renderPdfFirstPagePreview(String base64Pdf) async {
  final pages = await renderPdfPages(base64Pdf);
  if (pages.isEmpty) return null;
  return pages.first;
}

Future<List<String>> ocrPdfPages(String base64Pdf, int maxPages) async {
  final future = js_util.callMethod(html.window, 'ocrPdfPages', [base64Pdf, maxPages]);
  final pages = await js_util.promiseToFuture(future) as List<dynamic>;
  return pages.map((p) => p as String).toList();
}

Future<String> ocrDataUrl(String dataUrl) async {
  final future = js_util.callMethod(html.window, 'ocrDataUrl', [dataUrl]);
  final text = await js_util.promiseToFuture(future) as dynamic;
  return text as String;
}
