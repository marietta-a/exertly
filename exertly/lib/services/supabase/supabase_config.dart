import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads Supabase project credentials from the `.env` file (see `.env.example`).
class SupabaseConfig {
  SupabaseConfig._();

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Deep link Supabase redirects back to after OAuth (Google/Apple) sign-in
  /// or clicking an email confirmation link. Must be registered as a Redirect
  /// URL in the Supabase Auth dashboard, and match the URL scheme declared in
  /// AndroidManifest.xml / Info.plist.
  static const String authRedirectUrl = 'io.exertly.app://login-callback/';

  /// Storage bucket for user profile photos. Must be created in the Supabase
  /// dashboard with `image/jpeg`, `image/png` and `image/jpg` as the bucket's
  /// allowed MIME types.
  static const String avatarsBucket = 'avatars';
}
