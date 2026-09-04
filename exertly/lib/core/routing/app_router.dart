import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/screens/cv_builder_screen.dart';
import '../../presentation/screens/email_confirmation_screen.dart';
import '../../presentation/screens/job_opportunities_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/scholarship_finder_screen.dart';
import '../../presentation/screens/settings/account_management_screen.dart';
import '../../presentation/screens/settings/preferences_screen.dart';
import '../../presentation/screens/settings/security_settings_screen.dart';
import '../../presentation/screens/settings/settings_shell.dart';
import '../../presentation/screens/settings/theme_personalization_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final goingToCv = state.matchedLocation == '/cv-builder';
        final loggingIn = state.matchedLocation == '/login';
        final confirmingEmail = state.matchedLocation == '/confirm-email';

        if (goingToCv && !loggedIn) {
          return '/login';
        }

        if ((loggingIn || confirmingEmail) && loggedIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/confirm-email',
          builder: (context, state) => EmailConfirmationScreen(email: state.extra as String?),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/cv-builder',
          builder: (context, state) => const CvBuilderScreen(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobOpportunitiesScreen(),
        ),
        GoRoute(
          path: '/scholarships',
          builder: (context, state) => const ScholarshipFinderScreen(),
        ),
        
        // Base /settings route that redirects to split-pane on desktop
        GoRoute(
          path: '/settings',
          redirect: (context, state) {
            final size = MediaQuery.of(context).size;
            if (size.width > 800) {
              return '/settings/account';
            }
            return null; // Show index settings menu directory on mobile
          },
          builder: (context, state) => const SettingsScreen(),
        ),

        // Split-pane layout shell route for settings modules (Desktop wide layout)
        ShellRoute(
          builder: (context, state, child) {
            return SettingsShell(
              currentPath: state.matchedLocation,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/settings/account',
              builder: (context, state) => const AccountManagementScreen(),
            ),
            GoRoute(
              path: '/settings/preferences',
              builder: (context, state) => const PreferencesScreen(),
            ),
            GoRoute(
              path: '/settings/theme',
              builder: (context, state) => const ThemePersonalizationScreen(),
            ),
            GoRoute(
              path: '/settings/security',
              builder: (context, state) => const SecuritySettingsScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('No route defined for ${state.uri}'),
        ),
      ),
    );
  }
}
