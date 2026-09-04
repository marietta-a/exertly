import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_endpoints.dart';
import 'api_config.dart';

/// Thrown when Exertly.Api's storage endpoints respond with a non-2xx status.
class StorageApiException implements Exception {
  final int statusCode;
  final String message;

  StorageApiException(this.statusCode, this.message);

  @override
  String toString() => 'StorageApiException($statusCode): $message';
}

/// Talks to Exertly.Api's `/api/storage` endpoints, which proxy Supabase
/// Storage using the signed-in user's own Supabase access token — Supabase's
/// Row Level Security policies (`auth.uid() = owner`) still decide what's
/// allowed, this app just no longer calls Supabase Storage directly.
class StorageApiService {
  final http.Client _client;
  final String _baseUrl;
  final SupabaseClient _auth;

  StorageApiService({http.Client? client, String? baseUrl, SupabaseClient? auth})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _auth = auth ?? Supabase.instance.client;

  String? get _userId => _auth.auth.currentUser?.id;
  String? get _accessToken => _auth.auth.currentSession?.accessToken;

  Map<String, String> get _authHeaders {
    final token = _accessToken;
    return token == null ? const {} : {'Authorization': 'Bearer $token'};
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StorageApiException(
        response.statusCode,
        response.body.isNotEmpty ? response.body : response.reasonPhrase ?? 'Request failed',
      );
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  /// Uploads [bytes] to `<bucket>/<userId>/<fileName>`, overwriting any existing
  /// file at that path. Returns the storage path, or null if no user is signed in.
  Future<String?> uploadFile({
    required String bucket,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final userId = _userId;
    final token = _accessToken;
    if (userId == null || token == null) return null;

    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl${ApiEndpoints.storageFiles(bucket)}'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['userId'] = userId
      ..fields['fileName'] = fileName
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: contentType != null ? MediaType.parse(contentType) : null,
      ));

    final response = await http.Response.fromStream(await _client.send(request));
    final body = _decode(response) as Map<String, dynamic>?;
    return body?['path'] as String?;
  }

  /// Returns a time-limited signed URL for a private file, valid for [expiresInSeconds].
  Future<String?> getSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.storageSignedUrl(bucket)}')
        .replace(queryParameters: {'path': path, 'expiresIn': '$expiresInSeconds'});
    final response = await _client.get(uri, headers: _authHeaders);
    final body = _decode(response) as Map<String, dynamic>?;
    return body?['url'] as String?;
  }

  Future<void> deleteFile({required String bucket, required String path}) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.storageFiles(bucket)}');
    final response = await _client.delete(
      uri,
      headers: {..._authHeaders, 'Content-Type': 'application/json'},
      body: jsonEncode({'paths': [path]}),
    );
    _decode(response);
  }

  /// Returns a signed URL for the current signed-in user's most recently
  /// uploaded file within [bucket], or null if they have none or no user is
  /// signed in. File names are `<millisecondsSinceEpoch>.<ext>`, so the
  /// lexicographically-last name is also the most recent.
  Future<String?> getLatestUserFileSignedUrl(String bucket, {int expiresInSeconds = 3600}) async {
    final userId = _userId;
    if (userId == null) return null;
    final files = await listUserFiles(bucket);
    if (files.isEmpty) return null;
    files.sort();
    return getSignedUrl(bucket: bucket, path: '$userId/${files.last}', expiresInSeconds: expiresInSeconds);
  }

  /// Returns the public URL for a file in a public bucket (e.g. avatars).
  Future<String> getPublicUrl({required String bucket, required String path}) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.storagePublicUrl(bucket)}').replace(queryParameters: {'path': path});
    final response = await _client.get(uri);
    final body = _decode(response) as Map<String, dynamic>?;
    return body?['url'] as String? ?? '';
  }

  /// Lists files stored for the current signed-in user within [bucket].
  Future<List<String>> listUserFiles(String bucket) async {
    final userId = _userId;
    if (userId == null) return [];
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.storageFiles(bucket)}').replace(queryParameters: {'userId': userId});
    final response = await _client.get(uri, headers: _authHeaders);
    final body = _decode(response) as List<dynamic>?;
    return body?.map((entry) => entry['name'] as String).toList() ?? [];
  }

  /// Deletes every file stored for the current signed-in user within [bucket].
  Future<void> deleteAllUserFiles(String bucket) async {
    final userId = _userId;
    if (userId == null) return;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.storageAllFiles(bucket)}').replace(queryParameters: {'userId': userId});
    final response = await _client.delete(uri, headers: _authHeaders);
    _decode(response);
  }
}
