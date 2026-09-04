import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsShell extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const SettingsShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isDesktop) {
      // On mobile/tablet, don't use split shell; let the child render full screen
      return child;
    }

    // Sidebar items structure
    final items = [
      _SidebarItem(
        title: 'Account Management',
        icon: Icons.manage_accounts_rounded,
        path: '/settings/account',
      ),
      _SidebarItem(
        title: 'Preferences & Alerts',
        icon: Icons.tune_rounded,
        path: '/settings/preferences',
      ),
      _SidebarItem(
        title: 'Theme Personalization',
        icon: Icons.palette_rounded,
        path: '/settings/theme',
      ),
      _SidebarItem(
        title: 'Security & Integrity',
        icon: Icons.security_rounded,
        path: '/settings/security',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
            const SizedBox(width: 8),
            const Text(
              'System Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          // Left Sidebar Pane
          Container(
            width: 290,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: const Border(
                right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exertly Panel',
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your secure session config',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                
                // Sidebar List items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = currentPath == item.path;

                      return InkWell(
                        onTap: () {
                            context.go(item.path);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? colorScheme.primary.withOpacity(0.06) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border(left: BorderSide(color: colorScheme.secondary, width: 4))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.title +  '',
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.8),
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: isSelected 
                                    ? colorScheme.primary.withOpacity(0.5) 
                                    : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Sidebar Footer card
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.secondary.withOpacity(0.1),
                        radius: 16,
                        child: Icon(Icons.flash_on_rounded, color: colorScheme.secondary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Version 1.2.0',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            Text(
                              'Premium Active License',
                              style: TextStyle(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Right Content Pane
          Expanded(
            child: Theme(
              // Override app bar theme for embedded right-side views to look like standard canvas tabs!
              data: theme.copyWith(
                appBarTheme: theme.appBarTheme.copyWith(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  foregroundColor: colorScheme.primary,
                  elevation: 0,
                  iconTheme: IconThemeData(color: colorScheme.primary),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String title;
  final IconData icon;
  final String path;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.path,
  });
}
