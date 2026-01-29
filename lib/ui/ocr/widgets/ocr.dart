import 'package:aws_textract_api/textract-2018-06-27.dart';
import 'package:cleteci_cross_platform/ui/ocr/view_model/ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pdf_renderer.dart';

import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:image_picker/image_picker.dart';

class OCRScreen extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  OCRScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    TextractService? textractService,
    ImagePicker? imagePicker,
    String Function(String, {String? fallback})? envGetter,
  }) : _textractService = textractService,
        _imagePicker = imagePicker,
        _envGetter = envGetter ?? _safeEnvGetter;

  final String title;
  final IconData icon;
  final MaterialColor color;
  final TextractService? _textractService;
  final ImagePicker? _imagePicker;
  final String Function(String, {String? fallback}) _envGetter;

  // Safe environment getter that handles dotenv errors
  static String _safeEnvGetter(String key, {String? fallback}) {
    try {
      return dotenv.get(key, fallback: fallback ?? '');
    } catch (e) {
      // If dotenv is not available or key doesn't exist, return fallback
      return fallback ?? '';
    }
  }

  @override
  OCRScreenState createState() => OCRScreenState();
}

class OCRScreenState extends State<OCRScreen> {
  late final ImagePicker _picker;
  late final TextractService _textractService;

  // Textract Service Initialization
  late final String accessKey;
  late final String secretKey;
  late final String awsRegion;

  @override
  void initState() {
    super.initState();
    // Initialize dependencies
    _picker = widget._imagePicker ?? ImagePicker();

    // Initialize AWS credentials with fallback values first
    accessKey = widget._envGetter('AZ_ACCESS_KEY', fallback: '');
    secretKey = widget._envGetter('AZ_SECRET_KEY', fallback: '');
    awsRegion = widget._envGetter('AZ_REGION', fallback: 'us-east-1');

    // Then initialize textract service with the credentials
    _textractService = widget._textractService ?? _createTextractService();
  }

  TextractService _createTextractService() {
    final credentials = AwsClientCredentials(accessKey: accessKey, secretKey: secretKey);
    final service = Textract(region: awsRegion, credentials: credentials);
    return TextractService(service);
  }

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  Uint8List? _pickedPdfBytes;
  Uint8List? _pdfPreviewBytes;
  String? _pickedPdfName;
  String _extractedText = '';
  bool _isLoading = false;
  int _webOcrTotalPages = 0;
  int _webOcrProcessedPages = 0;
  final Map<String, List<String>> _webPdfPagesCache = {};

  void _debugLog(String message, [Object? error, StackTrace? st]) {
    final tag = '[OCR] ';
    try {
      debugPrint(tag + message);
      if (error != null) debugPrint('$tag Error: $error');
      if (st != null) debugPrint('$tag Stack: ${st.toString()}');
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _debugLog('Image picked: path=${pickedFile.path}');
        setState(() {
          _pickedImage = pickedFile;
          _extractedText = '';
        });
        try {
          final bytes = await pickedFile.readAsBytes();
          _debugLog('Picked image bytes length=${bytes.length}');
          setState(() {
            _pickedImageBytes = bytes;
          });
        } catch (e, st) {
          _debugLog('Failed reading image bytes', e, st);
        }
      }
    } catch (e) {
      _debugLog('Failed to pick image', e as Object, StackTrace.current);
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _pickPdf() async {
    // Forward to unified picker
    await _pickFile();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp', 'heic'],
        withData: true,
      );

      _debugLog('FilePicker returned ${result?.files.length ?? 0} files');

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final name = file.name;
      final bytes = file.bytes;

      _debugLog('Picked file: $name size=${bytes?.length ?? 0}');

      if (bytes == null) {
        _debugLog('No bytes available from picked file');
        _showErrorSnackbar('No se pudieron leer los bytes del archivo seleccionado.');
        return;
      }

      final ext = name.split('.').last.toLowerCase();

      setState(() {
        _pickedPdfBytes = null; 
        _pdfPreviewBytes = null;
        _pickedPdfName = null;
        _pickedImage = null;
        _pickedImageBytes = null;
        _extractedText = '';
      });

      if (ext == 'pdf') {
        _debugLog('Selected file is a PDF');
        setState(() {
          _pickedPdfBytes = bytes;
          _pickedPdfName = name;
          _pdfPreviewBytes = null;
        });

        if (kIsWeb) {
          _debugLog('Attempting web PDF rendering via pdf.js helper');
          try {
            final base64 = base64Encode(bytes);
            final pages = await renderPdfPages(base64);
            if (pages.isNotEmpty) {
              final String dataUrl = pages.first;
              final base64Part = dataUrl.split(',').last;
              final previewBytes = base64Decode(base64Part);
              setState(() {
                _pdfPreviewBytes = previewBytes;
              });
              _debugLog('Rendered PDF preview on web, pages=${pages.length}');
            }
            _webPdfPagesCache[name] = pages;
          } catch (e, st) {
            _debugLog('PDF web render error', e, st);
            _showErrorSnackbar('No se pudo generar vista previa del PDF en web: $e');
          }
        } else {
          try {
            _debugLog('Opening PDF for preview');
            final dynamic doc = await PdfDocument.openData(bytes as Uint8List);
            _debugLog('PDF opened, pageCount=${doc.pageCount}');
            final dynamic page = await doc.getPage(1);
            _debugLog('Got page 1: width=${page.width}, height=${page.height}');
            final dynamic pageImage = await page.render(
              width: page.width.toInt(),
              height: page.height.toInt(),
            );
            _debugLog('Rendered page 1');

            Uint8List? previewBytes;
            try {
              previewBytes = pageImage.bytes as Uint8List?;
            } catch (_) {}
            if (previewBytes == null) {
              try {
                final ui.Image img = pageImage.image as ui.Image;
                final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
                previewBytes = byteData?.buffer.asUint8List();
              } catch (_) {}
            }

            try {
              await page.close();
            } catch (_) {
              try {
                page.dispose();
              } catch (_) {}
            }
            try {
              await doc.close();
            } catch (_) {
              try {
                doc.dispose();
              } catch (_) {}
            }

            setState(() {
              _pdfPreviewBytes = previewBytes;
            });
          } catch (e, st) {
            _debugLog('Error generating PDF preview', e, st);
            _showErrorSnackbar('No se pudo generar vista previa del PDF: $e');
          }
        }
      } else {
        _debugLog('Selected file is an image');
        setState(() {
          _pickedImageBytes = bytes;
          _pickedPdfBytes = null;
          _pickedPdfName = null;
          _pdfPreviewBytes = null;
          _pickedImage = null;
        });
      }
    } catch (e, st) {
      _debugLog('Failed to pick file', e, st);
      _showErrorSnackbar('Failed to pick file: $e');
    }
  }

  Future<void> _processImage() async {
    if (_pickedImage == null && _pickedImageBytes == null && _pickedPdfBytes == null) {
      _showErrorSnackbar('Please select an image or PDF first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _extractedText = '';
    });

    try {
      if (_pickedPdfBytes != null) {
        final buffer = StringBuffer();
        if (kIsWeb) {
          // On web, use cached pages rendered via pdf.js helper
          final pages = _webPdfPagesCache[_pickedPdfName];
          if (pages == null || pages.isEmpty) {
            _debugLog('No cached web-rendered pages for $_pickedPdfName');
            _showErrorSnackbar('PDF no renderizado previamente en web. Selecciona el archivo de nuevo.');
            setState(() {
              _isLoading = false;
            });
            return;
          }

          // Use client-side OCR (Tesseract.js) on web when no backend is available.
          const int maxPages = 5;
          final int pagesToProcess = pages.length > maxPages ? maxPages : pages.length;
          _debugLog('Processing $pagesToProcess web pages with Tesseract (max $maxPages)');
          try {
            // process page-by-page to update progress
            setState(() {
              _webOcrTotalPages = pagesToProcess;
              _webOcrProcessedPages = 0;
            });

            for (int i = 0; i < pagesToProcess; i++) {
              final dataUrl = pages[i];
              final text = await ocrDataUrl(dataUrl);
              setState(() {
                _webOcrProcessedPages = i + 1;
              });
              if (text.isNotEmpty) {
                buffer.writeln('--- Página ${i + 1} ---');
                buffer.writeln(text);
              }
            }
          } catch (e, st) {
            _debugLog('Error running Tesseract on web', e, st);
            _showErrorSnackbar('Error procesando PDF en web: $e');
          } finally {
            setState(() {
              _webOcrTotalPages = 0;
              _webOcrProcessedPages = 0;
            });
          }

          setState(() {
            _extractedText = buffer.toString().trim();
          });
        } else {
          // Process each PDF page: render to PNG and call detectText (native platforms)
          final dynamic doc = await PdfDocument.openData(_pickedPdfBytes!);

          for (int i = 1; i <= doc.pageCount; i++) {
            final dynamic page = await doc.getPage(i);
            final dynamic pageImage = await page.render(
              width: page.width.toInt(),
              height: page.height.toInt(),
            );

            // attempt to extract bytes robustly
            Uint8List? pageBytes;
            try {
              pageBytes = pageImage.bytes as Uint8List?;
            } catch (_) {}

            if (pageBytes == null) {
              try {
                final ui.Image img = pageImage.image as ui.Image;
                final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
                pageBytes = byteData?.buffer.asUint8List();
              } catch (_) {}
            }

            try {
              await page.close();
            } catch (_) {
              try {
                page.dispose();
              } catch (_) {}
            }

            if (pageBytes != null) {
              final result = await _textractService.detectText(pageBytes);
              if (result.isNotEmpty) {
                buffer.writeln('--- Página $i ---');
                buffer.writeln(result);
              }
            } else {
              buffer.writeln('--- Página $i ---');
              buffer.writeln('No se pudo renderizar la página.');
            }
          }

          try {
            await doc.close();
          } catch (_) {
            try {
              doc.dispose();
            } catch (_) {}
          }

          setState(() {
            _extractedText = buffer.toString().trim();
          });
        }
      } else {
        Uint8List? imageBytes;
        if (_pickedImageBytes != null) {
          imageBytes = _pickedImageBytes;
        } else if (_pickedImage != null) {
          imageBytes = await _pickedImage!.readAsBytes();
        }

        if (imageBytes == null) {
          _showErrorSnackbar('No image bytes available for processing.');
        } else {
          final result = await _textractService.detectText(imageBytes);
          setState(() {
            _extractedText = result;
          });
        }
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;

    // Check if AWS credentials are available
    final hasCredentials = accessKey.isNotEmpty && secretKey.isNotEmpty && awsRegion.isNotEmpty;

    if (!hasCredentials) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuración de AWS incompleta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Las credenciales de AWS Textract no están configuradas correctamente. '
                  'Por favor contacte al administrador del sistema.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildImagePickerSection(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (_pickedImage != null || _pickedImageBytes != null || _pickedPdfBytes != null) && !_isLoading
                ? _processImage
                : null,
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Extract Text'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading && kIsWeb && _webOcrTotalPages > 0) ...[
              Text('Procesando página $_webOcrProcessedPages de $_webOcrTotalPages', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _webOcrTotalPages > 0 ? (_webOcrProcessedPages / _webOcrTotalPages) : null),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
            const Divider(),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: _pickedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20.0),
                    minScale: 0.1,
                    maxScale: 5.0,
                    child: Image.network(_pickedImage!.path),
                  ),
                )
              : _pickedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20.0),
                        minScale: 0.1,
                        maxScale: 5.0,
                        child: Image.memory(_pickedImageBytes!),
                      ),
                    )
                  : _pdfPreviewBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20.0),
                        minScale: 0.1,
                        maxScale: 5.0,
                        child: Image.memory(_pdfPreviewBytes!),
                      ),
                    )
                  : _pickedPdfName != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 64),
                              const SizedBox(height: 8),
                              Text(
                                _pickedPdfName!,
                                style: TextStyle(color: Theme.of(context).disabledColor),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'No image or PDF selected.',
                            style: TextStyle(color: Theme.of(context).disabledColor),
                          ),
                        ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File'),
            ),
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    try {
      _textractService.close();
    } catch (_) {}
    super.dispose();
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Extracted Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_extractedText.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy to Clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _extractedText));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text copied to clipboard')),
                    );
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Analyzing image..."),
                ],
              ),
            ),
          ),
        if (_extractedText.isNotEmpty && !_isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              _extractedText,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
      ],
    );
  }
}
