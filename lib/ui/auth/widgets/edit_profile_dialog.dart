import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_service.dart';

/// Diálogo para editar el perfil de usuario
class EditProfileDialog extends StatefulWidget {
  final UserProfile userProfile;
  final UserService? userService;

  const EditProfileDialog({
    super.key,
    required this.userProfile,
    this.userService,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  late final UserService _userService;

  XFile? _selectedAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _firstNameController.text = widget.userProfile.firstName;
    _lastNameController.text = widget.userProfile.lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Subir avatar si fue seleccionado (simplificado)
      String? avatarUrl = widget.userProfile.avatarUrl;
      if (_selectedAvatar != null) {
        // Aquí iría la lógica para subir la imagen a Firebase Storage
        // Por ahora, mantenemos el avatar existente
        avatarUrl = widget.userProfile.avatarUrl;
      }

      // Actualizar perfil en Firestore
      await _userService.updateUserProfile(
        uid: widget.userProfile.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado exitosamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: $e')),
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
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedAvatar != null
                          ? Image.network(_selectedAvatar!.path).image
                          : (widget.userProfile.avatarUrl != null
                              ? NetworkImage(widget.userProfile.avatarUrl!)
                              : null),
                      child: (_selectedAvatar == null && widget.userProfile.avatarUrl == null)
                          ? Text(
                              widget.userProfile.initials,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _pickAvatar(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: const Text('Galería'),
                        ),
                        TextButton.icon(
                          onPressed: () => _pickAvatar(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Cámara'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo de nombre
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingresa tu nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de apellido
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  hintText: 'Ingresa tu apellido',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu apellido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}