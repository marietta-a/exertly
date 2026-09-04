import 'package:flutter_test/flutter_test.dart';
import 'package:exertly/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthProvider Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      // AuthProvider reads Supabase.instance.client by default, so a client
      // must exist even though these tests never hit the network.
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        publishableKey: 'test-anon-key',
      );
    });

    test('Initializes in unauthenticated state', () {
      final authProvider = AuthProvider();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.userEmail, null);
    });

    test('logout is a no-op when there is no active session', () async {
      final authProvider = AuthProvider();
      await authProvider.logout();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.userEmail, null);
    });
  });
}
