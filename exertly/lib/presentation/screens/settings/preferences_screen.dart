import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _pushNotifications = true;
  bool _emailJobAlerts = true;
  bool _shareWithRecruiters = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences & Alerts'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.tune_rounded, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Communication Preferences',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Get alerts for instant resume reviews and matching job applications.', style: TextStyle(fontSize: 12)),
                      activeColor: colorScheme.secondary,
                      value: _pushNotifications,
                      onChanged: (val) => setState(() => _pushNotifications = val),
                    ),
                    const Divider(color: Color(0xFFE2E8F0)),
                    SwitchListTile(
                      title: const Text('Email Job Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Weekly curation of top executive roles matching your professional resume profiles.', style: TextStyle(fontSize: 12)),
                      activeColor: colorScheme.secondary,
                      value: _emailJobAlerts,
                      onChanged: (val) => setState(() => _emailJobAlerts = val),
                    ),
                    const Divider(color: Color(0xFFE2E8F0)),
                    SwitchListTile(
                      title: const Text('Share Profile with Recruiters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Allows verified corporate hiring managers to securely search and view your active CV details.', style: TextStyle(fontSize: 12)),
                      activeColor: colorScheme.secondary,
                      value: _shareWithRecruiters,
                      onChanged: (val) => setState(() => _shareWithRecruiters = val),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preferences saved successfully!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save Preferences'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
