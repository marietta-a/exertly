import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/auth_bottom_sheet.dart';
import 'widgets/navigation_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            // Procedural logo: Secondary color arrow rising through a circle
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: colorScheme.surface,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Exertly',
              style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
        actions: [
          if (Provider.of<AuthProvider>(context).isAuthenticated)
          ...[
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: 'Settings & Themes',
              onPressed: () => context.push('/settings'),
            ),
          ],
          if (Provider.of<AuthProvider>(context).isAuthenticated) ...[
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: Builder(
                builder: (context) {
                  final avatarUrl = Provider.of<AuthProvider>(context).avatarUrl;
                  return CircleAvatar(
                    backgroundColor: colorScheme.secondary.withOpacity(0.2),
                    radius: 18,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? null
                        : Text(
                            provider.resumeName.isNotEmpty ? provider.resumeName[0] : 'U',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: TextButton.icon(
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => context.go('/login'),
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Welcome Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 24.0,
                vertical: isDesktop ? 40.0 : 28.0,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Provider.of<AuthProvider>(context).isAuthenticated
                        ? 'Welcome back, ${provider.resumeName}!'
                        : 'Elevate Your Career with Exertly',
                    style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: isDesktop ? 36 : 26,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock your professional potential with custom resumes, ideal careers, and academic opportunities.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isDesktop ? 18 : 15,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.flash_on_rounded, size: 18),
                        label: const Text('Quick Build CV'),
                        onPressed: () {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          if (auth.isAuthenticated) {
                            context.push('/cv-builder');
                          } else {
                            AuthBottomSheet.show(
                              context,
                              title: 'Unlock CV Builder',
                              actionText: 'Unlock & Proceed',
                              onSuccess: () => context.push('/cv-builder'),
                            );
                          }
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.search_rounded, size: 18, color: Colors.white),
                        label: const Text('Search Jobs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => context.push('/jobs'),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.school_rounded, size: 18, color: Colors.white),
                        label: const Text('Search Scholarships'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => context.push('/scholarships'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content Area
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Navigation Hub',
                    style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 22,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a module to accelerate your professional journey',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Three Main Navigation Cards
                  _buildNavigationGrid(context, isDesktop, isTablet),

                  const SizedBox(height: 40),

                  // Dynamic Section with Previews
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Openings summary
                      Expanded(
                        flex: isDesktop ? 2 : 1,
                        child: _buildJobsPreviewSection(context, provider),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 24),
                        // Scholarships summary
                        Expanded(
                          flex: 1,
                          child: _buildScholarshipsPreviewSection(context, provider),
                        ),
                      ],
                    ],
                  ),
                  
                  if (!isDesktop) ...[
                    const SizedBox(height: 24),
                    _buildScholarshipsPreviewSection(context, provider),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context, bool isDesktop, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cards = [
      NavigationCard(
        title: 'CV/Resume Builder',
        subtitle: 'Build, edit, and export tailored professional resumes dynamically in seconds.',
        icon: Icons.edit_note_rounded,
        badgeText: '3 Templates Active',
        accentColor: colorScheme.secondary,
        onTap: () {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (auth.isAuthenticated) {
            context.push('/cv-builder');
          } else {
            AuthBottomSheet.show(
              context,
              title: 'Unlock CV Builder',
              actionText: 'Unlock & Customize CV',
              onSuccess: () => context.push('/cv-builder'),
            );
          }
        },
      ),
      NavigationCard(
        title: 'Job Opportunities',
        subtitle: 'Explore roles in Software Engineering, Marketing, Design, and more.',
        icon: Icons.business_center_rounded,
        badgeText: '24 New Roles',
        accentColor: colorScheme.primary,
        onTap: () => context.push('/jobs'),
      ),
      NavigationCard(
        title: 'Scholarship Finder',
        subtitle: 'Discover MBA leadership programs, STEM research grants, and global funding.',
        icon: Icons.school_rounded,
        badgeText: '12 Active Grants',
        accentColor: colorScheme.secondary,
        onTap: () => context.push('/scholarships'),
      ),
    ];

    if (isDesktop) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
        children: cards,
      );
    } else if (isTablet) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          cards[0],
          cards[1],
          // Span the third card across the screen
          GestureDetector(
            onTap: cards[2].onTap,
            child: cards[2],
          ),
        ],
      );
    } else {
      // Mobile vertical list
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => SizedBox(
          height: 200,
          child: cards[index],
        ),
      );
    }
  }

  Widget _buildJobsPreviewSection(BuildContext context, DashboardProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Jobs',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () => context.push('/jobs'),
                child: const Row(
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isLoadingJobs)
            Center(child: Padding(padding: const EdgeInsets.all(16), child: CircularProgressIndicator(color: colorScheme.primary)))
          else if (provider.jobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No job opportunities available right now.', style: TextStyle(color: Color(0xFF64748B))),
            )
          else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.jobs.length < 2 ? provider.jobs.length : 2, // Just top 2
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final job = provider.jobs[index];
              final isSaved = provider.savedJobs.contains(job.id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // Company Logo Circle Placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        job.logoText,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job.company} • ${job.location}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? colorScheme.secondary : Colors.grey,
                      ),
                      onPressed: () => provider.toggleSaveJob(job.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipsPreviewSection(BuildContext context, DashboardProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Grants',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () => context.push('/scholarships'),
                child: const Row(
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isLoadingScholarships)
            Center(child: Padding(padding: const EdgeInsets.all(16), child: CircularProgressIndicator(color: colorScheme.primary)))
          else if (provider.scholarships.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No scholarships available right now.', style: TextStyle(color: Color(0xFF64748B))),
            )
          else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.scholarships.length < 2 ? provider.scholarships.length : 2, // Just top 2
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final scholarship = provider.scholarships[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scholarship.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scholarship.institution,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          scholarship.amount,
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Deadline: ${scholarship.deadline}',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
