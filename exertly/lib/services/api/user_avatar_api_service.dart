import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_endpoints.dart';
import 'api_config.dart';

/// Thrown when Exertly.Api's user-avatar endpoints respond with a non-2xx status.
class UserAvatarApiException implements Exception {
  final int statusCode;
  final String message;

  UserAvatarApiException(this.statusCode, this.message);

  @override
  String toString() => 'UserAvatarApiException($statusCode): $message';
}

/// Mirrors a `user_avatars` row: one per user, holding their current
/// avatar's public URL (see Exertly.Api's `UserAvatar` model).
class UserAvatar {
  final int id;
  final String userId;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserAvatar({
    required this.id,
    required this.userId,
    required this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserAvatar.fromJson(Map<String, dynamic> json) => UserAvatar(
        id: json['id'] as int,
        userId: json['user_id'] as String,
        avatarUrl: json['avatar_url'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      );
}

/// Talks to Exertly.Api's `/api/user-avatars/{userId}` endpoints, which proxy
/// the `user_avatars` Supabase Postgres table using the signed-in user's own
/// Supabase access token — Supabase's Row Level Security policies
/// (`auth.uid() = user_id`) still decide what's allowed.
class UserAvatarApiService {
  final http.Client _client;
  final String _baseUrl;
  final SupabaseClient _auth;

  UserAvatarApiService({http.Client? client, String? baseUrl, SupabaseClient? auth})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _auth = auth ?? Supabase.instance.client;

  String? get _userId => _auth.auth.currentUser?.id;
  String? get _accessToken => _auth.auth.currentSession?.accessToken;

  Map<String, String> get _headers {
    final token = _accessToken;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  UserAvatar? _decode(http.Response response) {
    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserAvatarApiException(
        response.statusCode,
        response.body.isNotEmpty ? response.body : response.reasonPhrase ?? 'Request failed',
      );
    }
    if (response.body.isEmpty) return null;
    return UserAvatar.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Fetches the current user's avatar row, or null if none exists or no
  /// user is signed in.
  Future<UserAvatar?> getAvatar() async {
    final userId = _userId;
    if (userId == null) return null;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.userAvatar(userId)}');
    final response = await _client.get(uri, headers: _headers);
    return _decode(response);
  }

  /// Creates the current user's avatar row.
  Future<UserAvatar?> createAvatar(String avatarUrl) async {
    final userId = _userId;
    if (userId == null) return null;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.userAvatar(userId)}');
    final response = await _client.post(uri, headers: _headers, body: jsonEncode({'avatarUrl': avatarUrl}));
    return _decode(response);
  }

  /// Insert-or-replace the current user's avatar row, keyed by user id.
  Future<UserAvatar?> upsertAvatar(String avatarUrl) async {
    final userId = _userId;
    if (userId == null) return null;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.userAvatar(userId)}');
    final response = await _client.put(uri, headers: _headers, body: jsonEncode({'avatarUrl': avatarUrl}));
    return _decode(response);
  }

  /// Updates the current user's existing avatar row.
  Future<UserAvatar?> updateAvatar(String avatarUrl) async {
    final userId = _userId;
    if (userId == null) return null;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.userAvatar(userId)}');
    final response = await _client.patch(uri, headers: _headers, body: jsonEncode({'avatarUrl': avatarUrl}));
    return _decode(response);
  }

  /// Deletes the current user's avatar row.
  Future<void> deleteAvatar() async {
    final userId = _userId;
    if (userId == null) return;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.userAvatar(userId)}');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserAvatarApiException(
        response.statusCode,
        response.body.isNotEmpty ? response.body : response.reasonPhrase ?? 'Request failed',
      );
    }
  }
}
