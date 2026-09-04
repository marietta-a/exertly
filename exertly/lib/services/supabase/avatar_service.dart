import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'supabase_config.dart';
import 'supabase_storage_service.dart';

/// Picks, validates, compresses and uploads a user's profile photo to the
/// `avatars` Supabase Storage bucket. Persisting the resulting URL to the
/// `user_avatars` table is handled by AuthProvider, which owns the user's
/// avatar as reactive state.
class AvatarService {
  static const _allowedExtensions = {'jpg', 'jpeg', 'png'};
  static const _maxDimension = 512;
  static const _jpegQuality = 80;

  final ImagePicker _picker;
  final SupabaseStorageService _storage;

  AvatarService({ImagePicker? picker, SupabaseStorageService? storage})
      : _picker = picker ?? ImagePicker(),
        _storage = storage ?? SupabaseStorageService();

  Future<XFile?> pickAvatarImage() {
    return _picker.pickImage(source: ImageSource.gallery);
  }

  /// Cheap extension-based check against the bucket's allowed MIME types
  /// (image/jpeg, image/png, image/jpg). The image is still decoded before
  /// upload, which rejects anything that isn't actually a valid image.
  bool isAllowedFile(XFile file) {
    final ext = file.name.split('.').last.toLowerCase();
    return _allowedExtensions.contains(ext);
  }

  /// Compresses [file], deletes the user's previous avatar file(s) from the
  /// bucket, and uploads the new one under a fresh file name. Returns the
  /// new file's public URL. Throws [FormatException] if the file isn't a
  /// decodable image, and [StateError] if no user is signed in.
  Future<String> compressAndUpload(XFile file) async {
    if (!isAllowedFile(file)) {
      throw const FormatException('Only JPEG and PNG images are allowed.');
    }

    final original = await file.readAsBytes();
    final compressed = _compress(original);

    await _storage.deleteAllUserFiles(SupabaseConfig.avatarsBucket);

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = await _storage.uploadFile(
      bucket: SupabaseConfig.avatarsBucket,
      fileName: fileName,
      bytes: compressed,
      contentType: 'image/jpeg',
    );
    if (path == null) {
      throw StateError('You must be signed in to upload an avatar.');
    }

    return _storage.getPublicUrl(bucket: SupabaseConfig.avatarsBucket, path: path);
  }

  /// Deletes the current user's avatar file(s) from the bucket.
  Future<void> deleteStoredFiles() {
    return _storage.deleteAllUserFiles(SupabaseConfig.avatarsBucket);
  }

  Uint8List _compress(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unsupported or corrupt image file.');
    }

    var resized = decoded;
    if (decoded.width > _maxDimension || decoded.height > _maxDimension) {
      resized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: _maxDimension)
          : img.copyResize(decoded, height: _maxDimension);
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
  }
}
