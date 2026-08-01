// services/avatar_upload_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AvatarUploadService {
  AvatarUploadService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  static const String _rootFolder = 'avatars';

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    try {
      return await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );
    } catch (e) {
      throw AvatarUploadException('Failed to pick image: $e');
    }
  }

  /// Show image source selection dialog
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context,
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () async {
                        final image = await pickImage(
                          source: ImageSource.gallery,
                        );
                        if (context.mounted) Navigator.pop(context, image);
                      },
                    ),
                    _buildSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        final image = await pickImage(
                          source: ImageSource.camera,
                        );
                        if (context.mounted) Navigator.pop(context, image);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  /// Upload avatar to Firebase Storage at avatars/{userId}/{timestamp}.ext
  Future<String> uploadAvatar({
    required String userId,
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    final file = File(imageFile.path);
    if (!await file.exists()) {
      throw AvatarUploadException(
        'Image file not found at path: ${imageFile.path}',
      );
    }

    final extension = path.extension(imageFile.path).toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('$_rootFolder/$userId/$timestamp$extension');

    try {
      await _deleteOldAvatars(userId);

      final task = ref.putFile(
        file,
        SettableMetadata(contentType: _contentType(extension)),
      );

      if (onProgress != null) {
        task.snapshotEvents.listen((snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        });
      }

      await task;
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AvatarUploadException(
        e.message ?? 'Upload failed (${e.code}). Check Storage rules.',
      );
    } catch (e) {
      throw AvatarUploadException('Upload failed: $e');
    }
  }

  Future<void> _deleteOldAvatars(String userId) async {
    try {
      final folder = _storage.ref('$_rootFolder/$userId');
      final listing = await folder.listAll();
      for (final item in listing.items) {
        await item.delete();
      }
    } catch (e) {
      // Not critical - stale files just sit unused, upload still proceeds.
      debugPrint('Warning: failed to clear old avatars for $userId: $e');
    }
  }

  String _contentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Delete an avatar given its download URL.
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final ref = _storage.refFromURL(avatarUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw AvatarUploadException('Failed to delete avatar: ${e.message}');
    } catch (e) {
      throw AvatarUploadException('Failed to delete avatar: $e');
    }
  }
}

class AvatarUploadException implements Exception {
  final String message;
  AvatarUploadException(this.message);

  @override
  String toString() => message;
}
