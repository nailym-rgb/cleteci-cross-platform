import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camara_gallery_service.dart';

class CamaraGalleryServiceImpl implements CamaraGalleryService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo == null) {
      return null;
    }
    debugPrint('Photo taken: ${photo.path}');
    return photo.path;
  }

  @override
  Future<String?> selectPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) {
      return null;
    }
    debugPrint('Photo selected: ${photo.path}');
    return photo.path;
  }
}
