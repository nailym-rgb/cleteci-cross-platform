import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/auth_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/auth/sign_out_use_case.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/get_user_profile.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/update_user_profile.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/services/camara_gallery_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

class CustomUserProfileScreen extends StatefulWidget {
  CustomUserProfileScreen({
    super.key,
    GetUserProfile? getUserProfile,
    UpdateUserProfile? updateUserProfile,
    AuthRepository? authRepository,
    SignOutUseCase? signOutUseCase,
    CamaraGalleryService? camaraGalleryService,
  }) : _getUserProfile = getUserProfile ?? getIt<GetUserProfile>(),
       _updateUserProfile = updateUserProfile ?? getIt<UpdateUserProfile>(),
       _authRepository = authRepository ?? getIt<AuthRepository>(),
       _signOutUseCase = signOutUseCase ?? getIt<SignOutUseCase>(),
       _camaraGalleryService = camaraGalleryService ?? getIt<CamaraGalleryService>();

  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final AuthRepository _authRepository;
  final SignOutUseCase _signOutUseCase;
  final CamaraGalleryService _camaraGalleryService;

  @override
  State<CustomUserProfileScreen> createState() =>
      _CustomUserProfileScreenState();
}

class _CustomUserProfileScreenState extends State<CustomUserProfileScreen> {
  static const String signOutText = 'Cerrar Sesión';

  GetUserProfile get _getUserProfile => widget._getUserProfile;
  UpdateUserProfile get _updateUserProfile => widget._updateUserProfile;
  AuthRepository get _authRepository => widget._authRepository;
  SignOutUseCase get _signOutUseCase => widget._signOutUseCase;
  CamaraGalleryService get _camaraGalleryService => widget._camaraGalleryService;
  UserProfileEntity? _userProfile;

  // Controladores para edición directa
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  XFile? _selectedAvatar;

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
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) return;
      final profile = await _getUserProfile(uid);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar perfil: $e')));
      }
    }
  }

  // Métodos de auto-guardado eliminados para control manual

  Future<void> _createNewProfile() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    String? newAvatarUrl;
    try {
      if (_selectedAvatar != null) {
        String extension = path.extension(_selectedAvatar!.path);
        if (kIsWeb && extension.isEmpty) extension = '.png';

        String uniqueFileName =
            '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}$extension';

        String bucketName = dotenv.maybeGet('AWS_S3_BUCKET_NAME') ?? '';
        String region = dotenv.maybeGet('AWS_S3_REGION') ?? '';
        String accessKey = dotenv.maybeGet('AWS_S3_ACCESS_KEY') ?? '';
        String secretKey = dotenv.maybeGet('AWS_S3_SECRETY_KEY') ?? '';

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
          File file = File(_selectedAvatar!.path);

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
        newAvatarUrl =
            "https://$bucketName.s3.amazonaws.com/profiles/$uniqueFileName";
      }

      final now = DateTime.now();
      final newProfile = UserProfileEntity(
        uid: currentUser.uid,
        email: currentUser.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        avatarUrl: newAvatarUrl,
        createdAt: now,
        updatedAt: now,
      );
      await _updateUserProfile(newProfile);
      await _loadUserProfile();
    } catch (e) {
      debugPrint('Error en el registro: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error update profile: $e')));
      }
    }
  }

  Future<void> _updateExistingProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      String? newAvatarUrl;

      if (_selectedAvatar != null) {
        String extension = path.extension(_selectedAvatar!.path);
        if (kIsWeb && extension.isEmpty) extension = '.png';

        String uniqueFileName =
            '${_userProfile!.uid}_${DateTime.now().millisecondsSinceEpoch}$extension';

        String bucketName = dotenv.maybeGet('AWS_S3_BUCKET_NAME') ?? '';
        String region = dotenv.maybeGet('AWS_S3_REGION') ?? '';
        String accessKey = dotenv.maybeGet('AWS_S3_ACCESS_KEY') ?? '';
        String secretKey = dotenv.maybeGet('AWS_S3_SECRETY_KEY') ?? '';

        if (kIsWeb) {
          // En Web, necesitamos convertir el XFile a un formato que AWS S3 pueda manejar
          final Uint8List fileBytes = await _selectedAvatar!.readAsBytes();

          String response = await AwsS3.upload(
            accessKey: accessKey,
            secretKey: secretKey,
            file: fileBytes,
            bucket: bucketName,
            region: region,
            destDir:
                'profiles', // Crea una carpeta "perfiles" dentro del bucket
            filename: uniqueFileName,
          );

          debugPrint('S3 Upload Response: $response');
        } else {
          File file = File(_selectedAvatar!.path);

          String response = await AwsS3.uploadFile(
            accessKey: accessKey,
            secretKey: secretKey,
            file: file,
            bucket: bucketName,
            region: region,
            destDir:
                'profiles', // Crea una carpeta "perfiles" dentro del bucket
            filename: uniqueFileName,
          );

          debugPrint('S3 Upload Response: $response');
        }
        newAvatarUrl =
            "https://$bucketName.s3.amazonaws.com/profiles/$uniqueFileName";
      }

      final finalAvatarUrl = newAvatarUrl ?? _userProfile?.avatarUrl ?? '';

      final updatedProfile = _userProfile!.copyWith(
        firstName: firstName,
        lastName: lastName,
        avatarUrl: finalAvatarUrl,
        updatedAt: DateTime.now(),
      );
      await _updateUserProfile(updatedProfile);

      if (mounted) {
        setState(() {
          _userProfile = updatedProfile;
        });
      }
    } catch (e) {
      debugPrint('Error en el registro: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error update profile: $e')));
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessSnackBar() {
    if (!mounted) return;
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
      _showSuccessSnackBar();
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
            child: Icon(
              icon,
              size: 24,
              color: enabled ? null : Theme.of(context).disabledColor,
            ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                filled: !enabled,
                fillColor: enabled
                    ? null
                    : Theme.of(context).disabledColor.withValues(alpha: 0.1),
              ),
              style: TextStyle(
                fontSize: 16,
                color: enabled
                    ? null
                    : Theme.of(context).disabledColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    // 1. Creamos una variable para definir el proveedor de la imagen dinámicamente
    ImageProvider? getAvatarImage() {
      // 2. Si estamos en Web, leemos el "blob" como una imagen de red
      if (kIsWeb) {
        return _selectedAvatar != null
            ? NetworkImage(_selectedAvatar!.path)
            : (_userProfile?.avatarUrl != null
                  ? NetworkImage(_userProfile!.avatarUrl!)
                  : null);
      }
      // 3. Si estamos en Móvil, usamos el File tradicional
      else {
        return _selectedAvatar != null
            ? FileImage(File(_selectedAvatar!.path))
            : (_userProfile?.avatarUrl != null
                  ? NetworkImage(_userProfile!.avatarUrl!)
                  : null);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius: 50,
            backgroundImage: getAvatarImage(),
            child: _userProfile?.avatarUrl == null
                ? Text(
                    _userProfile?.initials ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final String? photoPath = await _camaraGalleryService
                      .selectPhoto();
                  if (photoPath == null) return;
                  setState(() {
                    _selectedAvatar = XFile(photoPath);
                  });
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final String? photoPath = await _camaraGalleryService
                      .takePhoto();
                  if (photoPath == null) return;
                  setState(() {
                    _selectedAvatar = XFile(photoPath);
                  });
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camara'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nombre completo
          Text(
            _userProfile?.fullName ?? 'Usuario',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // Email
          Text(
            _authRepository.currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.6),
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
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
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
                controller: TextEditingController(
                  text: _authRepository.currentUser?.email ?? '',
                ),
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
                crossAxisAlignment: isWeb
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.stretch,
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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(signOutText),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      await _signOutUseCase();
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
      body: FutureBuilder<UserProfileEntity?>(
        future: _authRepository.currentUser != null
            ? _getUserProfile(_authRepository.currentUser!.uid)
            : Future.value(null),
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
