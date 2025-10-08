// services/avatar_upload_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class AvatarUploadService {
  static const String _bucketName = 'pet_owner';

  final SupabaseClient _supabase;

  AvatarUploadService(this._supabase);

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    debugPrint('=== PICK IMAGE START ===');
    debugPrint(
      'Source: ${source == ImageSource.gallery ? "Gallery" : "Camera"}',
    );

    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image == null) {
        debugPrint('User cancelled image selection');
        return null;
      }

      debugPrint('Image picked successfully');
      debugPrint('Path: ${image.path}');
      debugPrint('Name: ${image.name}');
      debugPrint('MIME type: ${image.mimeType}');

      final file = File(image.path);
      final exists = await file.exists();
      debugPrint('File exists on device: $exists');

      if (exists) {
        final size = await file.length();
        debugPrint(
          'File size: ${size} bytes (${(size / 1024).toStringAsFixed(2)} KB)',
        );
      }

      debugPrint('=== PICK IMAGE END ===');
      return image;
    } catch (e, stackTrace) {
      debugPrint('=== PICK IMAGE ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw AvatarUploadException('Failed to pick image: $e');
    }
  }

  /// Show image source selection dialog
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    debugPrint('=== SHOWING IMAGE SOURCE DIALOG ===');

    return await showModalBottomSheet<XFile?>(
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
                        debugPrint('Gallery option selected');
                        final image = await pickImage(
                          source: ImageSource.gallery,
                        );
                        if (context.mounted) {
                          Navigator.pop(context, image);
                        }
                      },
                    ),
                    _buildSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        debugPrint('Camera option selected');
                        final image = await pickImage(
                          source: ImageSource.camera,
                        );
                        if (context.mounted) {
                          Navigator.pop(context, image);
                        }
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

  /// Upload avatar to Supabase storage
  Future<String> uploadAvatar({
    required String userId,
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    debugPrint('');
    debugPrint('==========================================');
    debugPrint('=== UPLOAD AVATAR START ===');
    debugPrint('==========================================');
    debugPrint('User ID: $userId');
    debugPrint('File path: ${imageFile.path}');
    debugPrint('File name: ${imageFile.name}');

    try {
      // Verify file exists
      final file = File(imageFile.path);
      final exists = await file.exists();
      debugPrint('File exists: $exists');

      if (!exists) {
        throw AvatarUploadException(
          'Image file not found at path: ${imageFile.path}',
        );
      }

      final fileSize = await file.length();
      debugPrint(
        'File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)',
      );

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path).toLowerCase();
      debugPrint('File extension: $extension');

      // New path structure: userId/timestamp.ext
      final filePath = '$userId/$timestamp$extension';
      debugPrint('Target path in bucket: $filePath');
      debugPrint('Bucket name: $_bucketName');

      // Delete old avatar if exists
      debugPrint('Attempting to delete old avatars...');
      await _deleteOldAvatar(userId);

      // Check authentication
      final currentUser = _supabase.auth.currentUser;
      debugPrint('Current user authenticated: ${currentUser != null}');
      if (currentUser != null) {
        debugPrint('Current user ID: ${currentUser.id}');
        debugPrint('Match with userId param: ${currentUser.id == userId}');
      }

      // Upload to Supabase storage
      debugPrint('Starting Supabase storage upload...');
      debugPrint('Content type: ${_getContentType(extension)}');

      try {
        await _supabase.storage
            .from(_bucketName)
            .upload(
              filePath,
              file,
              fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: false,
                contentType: _getContentType(extension),
              ),
            );
        debugPrint('✓ Upload to storage successful!');
      } catch (uploadError) {
        debugPrint('✗ Storage upload failed');
        debugPrint('Upload error type: ${uploadError.runtimeType}');
        debugPrint('Upload error: $uploadError');
        rethrow;
      }

      // Get public URL
      debugPrint('Getting public URL...');
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      debugPrint('✓ Public URL generated: $publicUrl');

      debugPrint('==========================================');
      debugPrint('=== UPLOAD AVATAR SUCCESS ===');
      debugPrint('==========================================');
      debugPrint('');

      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('=== STORAGE EXCEPTION ===');
      debugPrint('==========================================');
      debugPrint('Message: ${e.message}');
      debugPrint('Status Code: ${e.statusCode}');
      debugPrint('Error: $e');
      debugPrint('==========================================');
      debugPrint('');

      // Provide helpful error messages based on status code
      String userMessage;
      if (e.statusCode == '403') {
        userMessage =
            'Permission denied. Check storage policies in Supabase dashboard.';
      } else if (e.statusCode == '404') {
        userMessage = 'Bucket not found. Verify bucket "$_bucketName" exists.';
      } else if (e.statusCode == '409') {
        userMessage =
            'File already exists. This shouldn\'t happen with timestamp names.';
      } else {
        userMessage = e.message;
      }

      throw AvatarUploadException(userMessage);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('=== GENERAL EXCEPTION ===');
      debugPrint('==========================================');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      debugPrint('==========================================');
      debugPrint('');

      if (e is AvatarUploadException) rethrow;
      throw AvatarUploadException('Upload failed: $e');
    }
  }

  /// Delete old avatar files for a user
  Future<void> _deleteOldAvatar(String userId) async {
    debugPrint('--- Deleting old avatars for user: $userId ---');

    try {
      // List files in the user's folder (new structure)
      final response = await _supabase.storage
          .from(_bucketName)
          .list(path: userId);

      debugPrint('Found ${response.length} existing files to delete');

      // Delete all old files
      for (final file in response) {
        debugPrint('Deleting: $userId/${file.name}');
        await _supabase.storage.from(_bucketName).remove([
          '$userId/${file.name}',
        ]);
      }

      debugPrint('✓ Old avatars deleted successfully');
    } catch (e) {
      // Don't throw error if deletion fails
      debugPrint('⚠ Warning: Failed to delete old avatar: $e');
      debugPrint('This is not critical, continuing with upload...');
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
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

  /// Delete avatar
  Future<void> deleteAvatar(String avatarUrl) async {
    debugPrint('=== DELETE AVATAR START ===');
    debugPrint('Avatar URL: $avatarUrl');

    try {
      // Extract file path from URL
      final uri = Uri.parse(avatarUrl);
      debugPrint('Parsed URI: $uri');

      final pathSegments = uri.pathSegments;
      debugPrint('Path segments: $pathSegments');

      final bucketIndex = pathSegments.indexOf(_bucketName);
      debugPrint('Bucket index: $bucketIndex');

      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw AvatarUploadException('Invalid avatar URL format');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      debugPrint('File path to delete: $filePath');

      await _supabase.storage.from(_bucketName).remove([filePath]);
      debugPrint('✓ Avatar deleted successfully');
    } on StorageException catch (e) {
      debugPrint('=== STORAGE EXCEPTION ===');
      debugPrint('Error: ${e.message}');
      throw AvatarUploadException('Failed to delete avatar: ${e.message}');
    } catch (e) {
      debugPrint('=== DELETE ERROR ===');
      debugPrint('Error: $e');
      if (e is AvatarUploadException) rethrow;
      throw AvatarUploadException('Failed to delete avatar: $e');
    }
  }
}

/// Custom exception for avatar upload operations
class AvatarUploadException implements Exception {
  final String message;
  AvatarUploadException(this.message);

  @override
  String toString() => message;
}
