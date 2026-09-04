import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../api/storage_api_service.dart';
import 'supabase_config.dart';

/// Picks, validates, compresses and uploads a user's profile photo to the
/// `avatars` Supabase Storage bucket via Exertly.Api. The avatar itself is
/// the source of truth — there's no separate database row for it — so its
/// URL is always resolved by looking up the signed-in user's file(s) in the
/// bucket. AuthProvider owns the resulting URL as reactive state.
class AvatarService {
  static const _allowedExtensions = {'jpg', 'jpeg', 'png'};
  static const _maxDimension = 512;
  static const _jpegQuality = 80;

  final ImagePicker _picker;
  final StorageApiService _storage;

  AvatarService({ImagePicker? picker, StorageApiService? storage})
      : _picker = picker ?? ImagePicker(),
        _storage = storage ?? StorageApiService();

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
  /// bucket, and uploads the new one under a fresh file name. Returns a
  /// signed URL for the new file. Throws [FormatException] if the file isn't
  /// a decodable image, and [StateError] if no user is signed in.
  Future<String> compressAndUpload(XFile file) async {
    if (!isAllowedFile(file)) {
      throw const FormatException('Only JPEG and PNG images are allowed.');
    }

    final original = await file.readAsBytes();
    final compressed = _compress(original);

    await deleteStoredUserFiles();

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

    final url = await _storage.getSignedUrl(bucket: SupabaseConfig.avatarsBucket, path: path);
    if (url == null || url.isEmpty) {
      throw StateError('Unable to resolve the uploaded avatar\'s URL.');
    }
    return url;
  }

  /// Returns a signed URL for the current user's avatar, or null if they
  /// have none or no user is signed in.
  Future<String?> getAvatarUrl() {
    return _storage.getLatestUserFileSignedUrl(SupabaseConfig.avatarsBucket);
  }

  /// Deletes the current user's avatar file(s) from the bucket.
  Future<void> deleteStoredUserFiles() {
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
