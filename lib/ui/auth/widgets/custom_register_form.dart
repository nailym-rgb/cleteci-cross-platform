import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/user_service.dart';

/// Formulario personalizado de registro que incluye campos adicionales
class CustomRegisterForm extends StatefulWidget {
  const CustomRegisterForm({super.key});

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

  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();

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

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedAvatar = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
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
      // Crear usuario en Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Subir avatar si fue seleccionado (simplificado - en producción usarías Firebase Storage)
      String? avatarUrl;
      if (_selectedAvatar != null) {
        // Aquí iría la lógica para subir la imagen a Firebase Storage
        // Por ahora, solo guardamos null
        avatarUrl = null;
      }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: appTheme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con logo
           Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: SizedBox(
                                height: 80, // Altura fija más pequeña
                                child: SvgPicture.asset(
                                  'assets/cleteci_logo.svg',
                                  semanticsLabel: 'Cleteci Logo',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

            // Formulario centrado con ancho máximo
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector de avatar
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: _selectedAvatar != null
                                    ? Image.network(_selectedAvatar!.path).image
                                    : null,
                                child: _selectedAvatar == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _pickAvatar(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Galería'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _pickAvatar(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Cámara'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Campos del formulario con distribución similar al perfil
                        _buildFormField(
                          icon: Icons.person,
                          title: 'Nombre',
                          controller: _firstNameController,
                          hintText: 'Ingresa tu nombre',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        _buildFormField(
                          icon: Icons.person_outline,
                          title: 'Apellido',
                          controller: _lastNameController,
                          hintText: 'Ingresa tu apellido',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu apellido';
                            }
                            return null;
                          },
                        ),
                        _buildFormField(
                          icon: Icons.email,
                          title: 'Correo electrónico',
                          controller: _emailController,
                          hintText: 'correo@ejemplo.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo electrónico';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Por favor ingresa un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                        _buildFormField(
                          icon: Icons.lock,
                          title: 'Contraseña',
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        _buildFormField(
                          icon: Icons.lock_outline,
                          title: 'Confirmar contraseña',
                          controller: _confirmPasswordController,
                          hintText: 'Confirmar contraseña',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma tu contraseña';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Divider(),

            // Botones de acción
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth > 600;
                final buttonWidth = isWeb ? 400.0 : double.infinity;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: buttonWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: isWeb ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
                        children: [
                          // Botón de registro
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _register,
                            icon: const Icon(Icons.person_add),
                            label: _isLoading
                                ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                                : const Text('Registrarse'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              minimumSize: Size(buttonWidth, 48),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Enlace para ir al login
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
            ),
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
          SizedBox(
            width: 32,
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}