import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Storage for uploading/retrieving user files
/// (exported CVs, avatars, etc). Files are namespaced by the signed-in user's
/// id so Storage RLS policies can restrict access to `auth.uid() = owner`.
class SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Uploads [bytes] to `<bucket>/<userId>/<fileName>`, overwriting any existing
  /// file at that path. Returns the storage path, or null if no user is signed in.
  Future<String?> uploadFile({
    required String bucket,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final userId = _userId;
    if (userId == null) return null;

    final path = '$userId/$fileName';
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );
    return path;
  }

  /// Returns a time-limited signed URL for a private file, valid for [expiresInSeconds].
  Future<String?> getSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) {
    return _client.storage.from(bucket).createSignedUrl(path, expiresInSeconds);
  }

  Future<void> deleteFile({required String bucket, required String path}) {
    return _client.storage.from(bucket).remove([path]);
  }

  /// Returns the public URL for a file in a public bucket (e.g. avatars).
  String getPublicUrl({required String bucket, required String path}) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Lists files stored for the current signed-in user within [bucket].
  Future<List<FileObject>> listUserFiles(String bucket) async {
    final userId = _userId;
    if (userId == null) return [];
    return _client.storage.from(bucket).list(path: userId);
  }

  /// Deletes every file stored for the current signed-in user within [bucket].
  Future<void> deleteAllUserFiles(String bucket) async {
    final userId = _userId;
    if (userId == null) return;
    final files = await listUserFiles(bucket);
    if (files.isEmpty) return;
    await _client.storage.from(bucket).remove(files.map((f) => '$userId/${f.name}').toList());
  }
}
