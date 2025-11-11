import 'package:aws_textract_api/textract-2018-06-27.dart';
import 'package:cleteci_cross_platform/ui/ocr/view_model/ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  String _extractedText = '';
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
          _extractedText = '';
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_pickedImage == null) {
      _showErrorSnackbar('Please select an image first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _extractedText = '';
    });

    try {
      final imageBytes = await _pickedImage!.readAsBytes();
      final result = await _textractService.detectText(imageBytes);
      setState(() {
        _extractedText = result;
      });
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
              onPressed: _pickedImage != null && !_isLoading
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
              : Center(
                  child: Text(
                    'No image selected.',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
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
