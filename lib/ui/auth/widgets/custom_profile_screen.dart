import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_service.dart';

class CustomUserProfileScreen extends StatefulWidget {
  CustomUserProfileScreen({super.key, UserService? userService, FirebaseAuth? auth})
      : _userService = userService ?? UserService(),
        _auth = auth ?? FirebaseAuth.instance;

  final UserService _userService;
  final FirebaseAuth _auth;

  @override
  State<CustomUserProfileScreen> createState() => _CustomUserProfileScreenState();
}

class _CustomUserProfileScreenState extends State<CustomUserProfileScreen> {
  static const String signOutText = 'Cerrar Sesión';

  UserService get _userService => widget._userService;
  FirebaseAuth get _auth => widget._auth;
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

  Future<void> _createNewProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _userService.createUserProfile(
      uid: user.uid,
      email: user.email ?? '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    await _loadUserProfile();
  }

  Future<void> _updateExistingProfile() async {
    await _userService.updateUserProfile(
      uid: _userProfile!.uid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _userProfile = _userProfile!.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil guardado exitosamente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    try {
      if (_userProfile == null) {
        await _createNewProfile();
      } else {
        await _updateExistingProfile();
      }
      if (mounted) {
        _showSuccessSnackBar(context);
      }
    } catch (e) {
      _showErrorSnackBar('Error al guardar perfil: $e');
    }
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
            child: Icon(icon, size: 24, color: enabled ? null : Theme.of(context).disabledColor),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140, // Ancho fijo para alinear títulos
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: enabled ? null : Theme.of(context).disabledColor,
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
                fillColor: enabled ? null : Theme.of(context).disabledColor.withOpacity(0.1),
              ),
              style: TextStyle(
                fontSize: 16,
                color: enabled ? null : Theme.of(context).disabledColor.withOpacity(0.6),
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
            _auth.currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).disabledColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Error al cargar perfil: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserProfile,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const Divider(),
          _buildProfileForm(),
          const Divider(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Center(
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
                controller: TextEditingController(text: _auth.currentUser?.email ?? ''),
                hintText: 'correo@ejemplo.com',
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
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
                crossAxisAlignment: isWeb ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Configuración de Cuenta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _saveProfile(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: Size(buttonWidth, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función próximamente')),
                    ),
                    icon: const Icon(Icons.lock),
                    label: const Text('Cambiar Contraseña'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      minimumSize: Size(buttonWidth, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showSignOutDialog,
                    icon: const Icon(Icons.logout),
                    label: const Text(signOutText),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      minimumSize: Size(buttonWidth, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSignOutDialog() async {
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
            child: const Text(signOutText),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      await _auth.signOut();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder<UserProfile?>(
        future: _userService.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          _userProfile = snapshot.data;
          return _buildProfileContent();
        },
      ),
    );
  }
}
