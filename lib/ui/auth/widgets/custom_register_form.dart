import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cleteci_cross_platform/shared/infrastructure/services/camara_gallery_service_impl.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/user_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

/// Formulario personalizado de registro que incluye campos adicionales
class CustomRegisterForm extends StatefulWidget {
  CustomRegisterForm({super.key, UserService? userService, FirebaseAuth? auth})
    : _userService = userService ?? UserService(),
      _auth = auth ?? FirebaseAuth.instance;

  final UserService _userService;
  final FirebaseAuth _auth;

  @override
  State<CustomRegisterForm> createState() => _CustomRegisterFormState();
}

class _CustomRegisterFormState extends State<CustomRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserService get _userService => widget._userService;
  FirebaseAuth get _auth => widget._auth;

  XFile? _selectedAvatar;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String avatarUrl = ''; // Variable para almacenar la URL del avatar subido

      if (_selectedAvatar != null) {
        String extension = path.extension(_selectedAvatar!.path);
        if (kIsWeb && extension.isEmpty) extension = '.png';

        String uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}$extension';

        String bucketName = dotenv.maybeGet('AWS_S3_BUCKET_NAME') ?? '';
        String region = dotenv.maybeGet('AWS_S3_REGION') ?? '';
        String accessKey = dotenv.maybeGet('AWS_S3_ACCESS_KEY') ?? '';
        String secretKey = dotenv.maybeGet('AWS_S3_SECRETY_KEY') ?? '';
        File file = File(_selectedAvatar!.path);

        if (kIsWeb) {
          // En Web, necesitamos convertir el XFile a un formato que AWS S3 pueda manejar
          final Uint8List fileBytes = await _selectedAvatar!.readAsBytes();

          await AwsS3.upload(
            accessKey: accessKey,
            secretKey: secretKey,
            file: fileBytes,
            bucket: bucketName,
            region: region,
            destDir:
                'profiles', // Crea una carpeta "perfiles" dentro del bucket
            filename: uniqueFileName,
          );
        } else {
          // En Móvil, el XFile ya es un File válido
          await AwsS3.uploadFile(
            accessKey: accessKey,
            secretKey: secretKey,
            file: file,
            bucket: bucketName,
            region: region,
            destDir:
                'profiles', // Crea una carpeta "perfiles" dentro del bucket
            filename: uniqueFileName,
          );
        }

        avatarUrl =
            "https://$bucketName.s3.amazonaws.com/profiles/$uniqueFileName";
      }

      // Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Crear perfil en Firestore
      await _userService.createUserProfile(
        uid: userCredential.user!.uid,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Registro exitoso! Redirigiendo al login...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Redireccionar al login después de un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      debugPrint('Error en el registro: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en el registro: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        height: 80,
        child: SvgPicture.asset(
          'assets/cleteci_logo.svg',
          semanticsLabel: 'Cleteci Logo',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    // 1. Creamos una variable para definir el proveedor de la imagen dinámicamente
    ImageProvider? getAvatarImage() {
      if (_selectedAvatar == null) return null;

      // 2. Si estamos en Web, leemos el "blob" como una imagen de red
      if (kIsWeb) {
        return NetworkImage(_selectedAvatar!.path);
      }
      // 3. Si estamos en Móvil, usamos el File tradicional
      else {
        return FileImage(File(_selectedAvatar!.path));
      }
    }

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: getAvatarImage(),
            child: _selectedAvatar == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final String? photoPath = await CamaraGalleryServiceImpl()
                      .selectPhoto();
                  if (photoPath == null) return;
                  setState(() {
                    _selectedAvatar = XFile(photoPath);
                  });
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final String? photoPath = await CamaraGalleryServiceImpl()
                      .takePhoto();
                  if (photoPath == null) return;
                  setState(() {
                    _selectedAvatar = XFile(photoPath);
                  });
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSelector(),
                const SizedBox(height: 24),
                _buildFormFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildFormField(
          icon: Icons.person,
          title: 'Nombre',
          controller: _firstNameController,
          hintText: 'Ingresa tu nombre',
          validator: (value) => value == null || value.isEmpty
              ? 'Por favor ingresa tu nombre'
              : null,
        ),
        _buildFormField(
          icon: Icons.person_outline,
          title: 'Apellido',
          controller: _lastNameController,
          hintText: 'Ingresa tu apellido',
          validator: (value) => value == null || value.isEmpty
              ? 'Por favor ingresa tu apellido'
              : null,
        ),
        _buildFormField(
          icon: Icons.email,
          title: 'Correo electrónico',
          controller: _emailController,
          hintText: 'correo@ejemplo.com',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        _buildFormField(
          icon: Icons.lock,
          title: 'Contraseña',
          controller: _passwordController,
          hintText: 'Contraseña',
          obscureText: true,
          validator: _validatePassword,
        ),
        _buildFormField(
          icon: Icons.lock_outline,
          title: 'Confirmar contraseña',
          controller: _confirmPasswordController,
          hintText: 'Confirmar contraseña',
          obscureText: true,
          validator: (value) => value == null || value.isEmpty
              ? 'Por favor confirma tu contraseña'
              : null,
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    if (!EmailValidator.validate(value)) {
      return 'Por favor ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;
        final buttonWidth = isWeb ? 400.0 : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: buttonWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: isWeb
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _register,
                    icon: const Icon(Icons.person_add),
                    label: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : const Text('Registrarse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: Size(buttonWidth, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
            const Divider(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 32, child: Icon(icon, size: 24)),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
