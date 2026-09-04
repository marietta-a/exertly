import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings & Personalization'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings Directory',
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a module to manage your profile, customize preferences, or personalize themes.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Settings Menu Cards
                _buildMenuCard(
                  context,
                  title: 'Account Management',
                  subtitle: 'Edit your credential details, professional titles, and contact cards.',
                  icon: Icons.manage_accounts_rounded,
                  accentColor: colorScheme.secondary,
                  onTap: () => context.push('/settings/account'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: 'Preferences & Communication',
                  subtitle: 'Set up push alerts, job notifications, and recruiter share parameters.',
                  icon: Icons.tune_rounded,
                  accentColor: colorScheme.primary,
                  onTap: () => context.push('/settings/preferences'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: 'Theme Personalization',
                  subtitle: 'Switch preset color system designs to match your branding aesthetics.',
                  icon: Icons.palette_rounded,
                  accentColor: colorScheme.secondary,
                  onTap: () => context.push('/settings/theme'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: 'Security & Integrity',
                  subtitle: 'Securely wipe local profiles, cached references, and deactivate privileges.',
                  icon: Icons.security_rounded,
                  accentColor: Colors.redAccent,
                  onTap: () => context.push('/settings/security'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 20),
              // Text descriptions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
