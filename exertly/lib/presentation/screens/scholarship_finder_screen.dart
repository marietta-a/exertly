import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/auth_bottom_sheet.dart';

class ScholarshipFinderScreen extends StatefulWidget {
  const ScholarshipFinderScreen({super.key});

  @override
  State<ScholarshipFinderScreen> createState() => _ScholarshipFinderScreenState();
}

class _ScholarshipFinderScreenState extends State<ScholarshipFinderScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Business', 'Technology', 'Multidisciplinary', 'Europe'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter scholarships based on search query and category
    final filteredScholarships = provider.scholarships.where((scholarship) {
      final matchesSearch = scholarship.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scholarship.institution.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scholarship.category.toLowerCase().contains(_searchQuery.toLowerCase());
          
      final matchesCategory = _selectedCategory == 'All' || 
          scholarship.category.contains(_selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Scholarship Finder'),
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
                    hintText: 'Search scholarships, grants, or institutions...',
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
                        labelStyle: const TextStyle(
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

          // Scholarship Listings View
          Expanded(
            child: provider.isLoadingScholarships
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : provider.scholarshipsError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.primary.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              provider.scholarshipsError!,
                              style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: provider.loadScholarships,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredScholarships.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: colorScheme.primary.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No matching scholarships found',
                          style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredScholarships.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final scholarship = filteredScholarships[index];
                      final isApplied = provider.appliedScholarships.contains(scholarship.id);
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
                                  // Graduation Cap Icon Badge
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: colorScheme.secondary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scholarship.title,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          scholarship.institution,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                                color: colorScheme.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Applied Indicator
                                  if (isApplied)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green.withOpacity(0.2)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'Applied',
                                            style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Funding Amount & Deadline Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      context,
                                      'FUNDING AMOUNT',
                                      scholarship.amount,
                                      Icons.payments_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildMetricTile(
                                      context,
                                      'APPLICATION DEADLINE',
                                      scholarship.deadline,
                                      Icons.calendar_month_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Category Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      scholarship.category,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                    ),
                                  ),
                                  // Toggle Applied
                                  ElevatedButton(
                                    onPressed: () {
                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                      
                                      void toggleAction() {
                                        provider.toggleApplyScholarship(scholarship.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isApplied 
                                                  ? 'Withdrew application from ${scholarship.title}' 
                                                  : 'Application submitted for ${scholarship.title}! Compiled using your active resume.',
                                            ),
                                            backgroundColor: colorScheme.primary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }

                                      if (auth.isAuthenticated) {
                                        toggleAction();
                                      } else {
                                        AuthBottomSheet.show(
                                          context,
                                          title: 'Unlock Scholarship Entry',
                                          actionText: 'Unlock & Apply',
                                          onSuccess: toggleAction,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isApplied ? colorScheme.primary : colorScheme.secondary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(isApplied ? 'Withdraw Apply' : 'Apply for Grant'),
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

  Widget _buildMetricTile(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
