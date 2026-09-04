import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase/avatar_service.dart';
import '../services/supabase/supabase_config.dart';

/// Table holding each user's current avatar URL: columns `user_id` and
/// `avatar_url` (the public URL of the file stored in the `avatars` bucket).
const String _userAvatarsTable = 'user_avatars';

/// Wraps Supabase Auth: email/password sign-in and sign-up, plus Google/Apple
/// OAuth (redirect flow). Until the Google/Apple providers are configured in
/// the Supabase dashboard, those specific calls will reach Supabase but the
/// provider redirect itself will fail server-side.
///
/// Also owns the signed-in user's avatar as reactive state, backed by the
/// `user_avatars` table and the `avatars` storage bucket (see [AvatarService]).
class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client;
  final AvatarService _avatarService;
  late final StreamSubscription<AuthState> _authSub;

  AuthProvider({SupabaseClient? client, AvatarService? avatarService})
      : _client = client ?? Supabase.instance.client,
        _avatarService = avatarService ?? AvatarService() {
    _authSub = _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
      _refreshAvatarUrl();
    });
    _refreshAvatarUrl();
  }

  bool _isLoading = false;
  String? _errorMessage;
  String? _avatarUrl;

  bool get isAuthenticated => _client.auth.currentSession != null;
  String? get userEmail => _client.auth.currentUser?.email;
  String? get avatarUrl => _avatarUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Reloads the signed-in user's avatar URL from the `user_avatars` table.
  Future<void> _refreshAvatarUrl() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (_avatarUrl != null) {
        _avatarUrl = null;
        notifyListeners();
      }
      return;
    }
    try {
      final row = await _client.from(_userAvatarsTable).select('avatar_url').eq('user_id', userId).maybeSingle();
      _avatarUrl = row?['avatar_url'] as String?;
    } catch (_) {
      // Keep whatever avatar is already cached if the fetch fails.
    }
    notifyListeners();
  }

  /// Signs in with an existing email/password account.
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var res = await _client.auth.signInWithPassword(email: email, password: password);
      if(res.user == null) {
        _errorMessage = 'Email confirmation required. Please check your inbox.';
        return false;
      }
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unable to reach Supabase authentication.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new email/password account. If the Supabase project requires
  /// email confirmation, the returned session will be null even on success —
  /// callers should check [isAuthenticated] afterwards to decide messaging.
  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: SupabaseConfig.authRedirectUrl,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unable to reach Supabase authentication.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-sends the signup confirmation email. Used by the email confirmation
  /// screen when a user didn't receive (or lost) the original link.
  Future<bool> resendConfirmationEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: SupabaseConfig.authRedirectUrl,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unable to reach Supabase authentication.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() => _signInWithOAuth(OAuthProvider.google);

  Future<bool> signInWithApple() => _signInWithOAuth(OAuthProvider.apple);

  Future<bool> _signInWithOAuth(OAuthProvider provider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _client.auth.signInWithOAuth(
        provider,
        redirectTo: SupabaseConfig.authRedirectUrl,
      );
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unable to reach Supabase authentication.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Persists the uploaded avatar's public URL as the user's row in
  /// `user_avatars` (insert or replace, keyed by `user_id`).
  Future<bool> updateAvatarUrl(String url) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'You must be signed in to update your avatar.';
      notifyListeners();
      return false;
    }
    try {
      await _client.from(_userAvatarsTable).upsert({'user_id': userId, 'avatar_url': url}, onConflict: 'user_id');
      _avatarUrl = url;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Unable to save the new profile photo.';
      notifyListeners();
      return false;
    }
  }

  /// Deletes the user's avatar file(s) from storage and its `user_avatars` row.
  Future<bool> deleteAvatar() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await _avatarService.deleteStoredFiles();
      await _client.from(_userAvatarsTable).delete().eq('user_id', userId);
      _avatarUrl = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Unable to remove the profile photo.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Best-effort: local session is already cleared regardless.
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
