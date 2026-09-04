import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/auth_bottom_sheet.dart';

class JobOpportunitiesScreen extends StatefulWidget {
  const JobOpportunitiesScreen({super.key});

  @override
  State<JobOpportunitiesScreen> createState() => _JobOpportunitiesScreenState();
}

class _JobOpportunitiesScreenState extends State<JobOpportunitiesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Flutter', 'Growth', 'UI/UX', 'SQL', 'Python'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Filter jobs based on search query and category
    final filteredJobs = provider.jobs.where((job) {
      final matchesSearch = job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(_searchQuery.toLowerCase());
          
      final matchesCategory = _selectedCategory == 'All' || 
          job.tags.contains(_selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Job Opportunities'),
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: colorScheme.primary,
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search roles, companies, or locations...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Categories Horizontal List
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        selectedColor: colorScheme.secondary,
                        backgroundColor: colorScheme.primary.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Job Listings View
          Expanded(
            child: provider.isLoadingJobs
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : provider.jobsError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.primary.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              provider.jobsError!,
                              style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: provider.loadJobs,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: colorScheme.primary.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No matching job opportunities found',
                          style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredJobs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      final isSaved = provider.savedJobs.contains(job.id);
                      return Card(
                        color: colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Logo Circle
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      job.logoText,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
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
                                          style: theme.textTheme.titleLarge?.copyWith(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          job.company,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                                color: colorScheme.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      color: isSaved ? colorScheme.secondary : const Color(0xFF64748B),
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                      if (auth.isAuthenticated) {
                                        provider.toggleSaveJob(job.id);
                                      } else {
                                        AuthBottomSheet.show(
                                          context,
                                          title: 'Authentication Required',
                                          actionText: 'Unlock Bookmarks',
                                          onSuccess: () => provider.toggleSaveJob(job.id),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Location, Salary & Type Info Row
                              Row(
                                children: [
                                  _buildInfoIconText(context, Icons.location_on_rounded, job.location),
                                  const SizedBox(width: 16),
                                  _buildInfoIconText(context, Icons.monetization_on_rounded, job.salaryRange),
                                  const SizedBox(width: 16),
                                  _buildInfoIconText(context, Icons.access_time_filled_rounded, job.employmentType),
                                ],
                              ),
                              if (job.details.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  job.details,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Tags Row
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: job.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Details Button
                                  OutlinedButton(
                                    onPressed: () {
                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                      if (auth.isAuthenticated) {
                                        _showDetailsDialog(context, job);
                                      } else {
                                        AuthBottomSheet.show(
                                          context,
                                          title: 'Authentication Required',
                                          actionText: 'Unlock Details',
                                          onSuccess: () => _showDetailsDialog(context, job),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                                    ),
                                    child: const Text('Details'),
                                  ),
                                  const SizedBox(width: 8),
                                  // Apply Button
                                  ElevatedButton(
                                    onPressed: () {
                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                      if (auth.isAuthenticated) {
                                        _showApplyDialog(context, job, provider);
                                      } else {
                                        AuthBottomSheet.show(
                                          context,
                                          title: 'Unlock Application Module',
                                          actionText: 'Unlock & Submit Profile',
                                          onSuccess: () => _showApplyDialog(context, job, provider),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.secondary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Apply Now'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIconText(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _openPostingLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the posting link.')),
      );
    }
  }

  void _showDetailsDialog(BuildContext context, JobListing job) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            job.title,
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${job.company} · ${job.location}',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Employment Type', job.employmentType),
                  _buildDetailRow('Work Arrangement', job.workArrangement),
                  _buildDetailRow('Date Posted', job.datePosted),
                  if (job.sponsorshipAvailable) _buildDetailRow('Visa Sponsorship', 'Available'),
                  const SizedBox(height: 8),
                  Text(
                    job.details.isNotEmpty ? job.details : 'No further details are available for this role.',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFF64748B))),
            ),
            if (job.postingLink.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openPostingLink(context, job.postingLink),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('View Original Posting'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showApplyDialog(BuildContext context, dynamic job, DashboardProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Apply to ${job.company}',
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm your dynamic application profile:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.resumeName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary),
                      ),
                      Text(
                        provider.resumeTitle,
                        style: TextStyle(fontSize: 12, color: colorScheme.secondary, fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 16),
                      Text('Email: ${provider.resumeEmail}', style: const TextStyle(fontSize: 11)),
                      Text('Phone: ${provider.resumePhone}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 8),
                      Text(
                        'Skills: ${provider.resumeSkills.join(", ")}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'By applying, Exertly will compile your active CV using your selected theme, and instantly file your digital application alongside references.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final message = await provider.applyToJob(job.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(child: Text(message)),
                      ],
                    ),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );
  }
}
