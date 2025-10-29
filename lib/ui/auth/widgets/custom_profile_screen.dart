import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_service.dart';

class CustomUserProfileScreen extends StatefulWidget {
  const CustomUserProfileScreen({super.key});

  @override
  State<CustomUserProfileScreen> createState() => _CustomUserProfileScreenState();
}

class _CustomUserProfileScreenState extends State<CustomUserProfileScreen> {
  final UserService _userService = UserService();
  UserProfile? _userProfile;

  // Controladores para edición directa
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _loadUserProfile();

    // Los listeners están deshabilitados para evitar auto-guardado
    // Solo se guarda cuando el usuario hace clic en "Guardar Cambios"
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          if (profile != null) {
            _firstNameController.text = profile.firstName;
            _lastNameController.text = profile.lastName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil: $e')),
        );
      }
    }
  }

  // Métodos de auto-guardado eliminados para control manual

  Future<void> _saveProfile() async {
    print('Iniciando guardado manual del perfil');
    print('_userProfile: $_userProfile');
    print('firstName: ${_firstNameController.text}');
    print('lastName: ${_lastNameController.text}');

    if (_userProfile == null) {
      print('No hay perfil de usuario, creando uno nuevo');
      // Si no hay perfil, intentar crear uno
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _userService.createUserProfile(
            uid: user.uid,
            email: user.email ?? '',
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
          // Recargar perfil
          await _loadUserProfile();
        }
      } catch (e) {
        print('Error al crear perfil: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear perfil: $e')),
          );
        }
        return;
      }
    } else {
      print('Actualizando perfil existente');
      try {
        await _userService.updateUserProfile(
          uid: _userProfile!.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );

        // Actualizar perfil local
        if (mounted) {
          setState(() {
            _userProfile = _userProfile!.copyWith(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              updatedAt: DateTime.now(),
            );
          });
        }
      } catch (e) {
        print('Error al actualizar perfil: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar perfil: $e')),
          );
        }
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil guardado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    print('Perfil guardado exitosamente');
  }

  Widget _buildEditableField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32, // Ancho fijo para alinear iconos
            child: Icon(icon, size: 24, color: enabled ? null : Colors.grey),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140, // Ancho fijo para alinear títulos
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: enabled ? null : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: !enabled,
                fillColor: enabled ? null : Colors.grey[100],
              ),
              style: TextStyle(
                fontSize: 16,
                color: enabled ? null : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius: 50,
            backgroundImage: _userProfile?.avatarUrl != null
                ? NetworkImage(_userProfile!.avatarUrl!)
                : null,
            child: _userProfile?.avatarUrl == null
                ? Text(
                    _userProfile?.initials ?? 'U',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Nombre completo
          Text(
            _userProfile?.fullName ?? 'Usuario',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: appTheme.colorScheme.primary,
      ),
      body: FutureBuilder<UserProfile?>(
        future: _userService.getCurrentUserProfile(),
        builder: (context, snapshot) {
          print('FutureBuilder state: ${snapshot.connectionState}');
          print('FutureBuilder hasData: ${snapshot.hasData}');
          print('FutureBuilder hasError: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('FutureBuilder error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            print('FutureBuilder data: ${snapshot.data}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar perfil: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          _userProfile = snapshot.data;
          print('Asignando _userProfile: $_userProfile');

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(),
                const Divider(),

                // Información adicional del perfil
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditableField(
                            icon: Icons.person,
                            title: 'Nombre',
                            controller: _firstNameController,
                            hintText: 'Ingresa tu nombre',
                          ),
                          _buildEditableField(
                            icon: Icons.person_outline,
                            title: 'Apellido',
                            controller: _lastNameController,
                            hintText: 'Ingresa tu apellido',
                          ),
                          _buildEditableField(
                            icon: Icons.email,
                            title: 'Correo electrónico',
                            controller: TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? ''),
                            hintText: 'correo@ejemplo.com',
                            enabled: false,
                          ),
                          _buildEditableField(
                            icon: Icons.calendar_today,
                            title: 'Miembro desde',
                            controller: TextEditingController(
                              text: _userProfile?.createdAt != null
                                  ? '${_userProfile!.createdAt.day}/${_userProfile!.createdAt.month}/${_userProfile!.createdAt.year}'
                                  : 'Fecha no disponible',
                            ),
                            hintText: 'Fecha de registro',
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(),

                // Botones de acción simples en lugar de ProfileScreen completo
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Determinar si es web (ancho > 600) o mobile
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
                              const Text(
                                'Configuración de Cuenta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),

                              // Botón de guardar cambios
                              ElevatedButton.icon(
                                onPressed: _saveProfile,
                                icon: const Icon(Icons.save),
                                label: const Text('Guardar Cambios'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(buttonWidth, 48),
                                ),
                              ),
                              const SizedBox(height: 12),

                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Implementar cambio de contraseña
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Función próximamente')),
                                  );
                                },
                                icon: const Icon(Icons.lock),
                                label: const Text('Cambiar Contraseña'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(buttonWidth, 48),
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final shouldSignOut = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Cerrar Sesión'),
                                      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Cerrar Sesión'),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (shouldSignOut == true && mounted) {
                                    await FirebaseAuth.instance.signOut();
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Cerrar Sesión'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  minimumSize: Size(buttonWidth, 48),
                                ),
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
          );
        },
      ),
    );
  }
}
