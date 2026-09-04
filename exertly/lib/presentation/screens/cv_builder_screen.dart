import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/cv_exporter/cv_exporter.dart';
import '../../services/supabase/resume_file_service.dart';
import '../widgets/auth_bottom_sheet.dart';

class CvBuilderScreen extends StatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _summaryController;
  
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _newSectionTitleController = TextEditingController();

  // Controllers for adding a new empty role card
  final TextEditingController _newRoleController = TextEditingController();
  final TextEditingController _newCompanyController = TextEditingController();
  final TextEditingController _newPeriodController = TextEditingController();

  final List<String> _suggestedSections = [
    'Certifications',
    'Languages',
    'Awards & Honors',
    'Publications',
    'Volunteering',
    'Academic Projects',
    'Professional Affiliations',
    'Interests',
  ];

  bool _controllersSynced = false;

  final _resumeFileService = ResumeFileService();
  String? _storedResumeUrl;
  bool _isLoadingStoredResume = true;
  bool _isUploadingResume = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _summaryController = TextEditingController();
    _loadStoredResume();
  }

  Future<void> _loadStoredResume() async {
    try {
      final url = await _resumeFileService.getStoredResumeUrl();
      if (!mounted) return;
      setState(() {
        _storedResumeUrl = url;
        _isLoadingStoredResume = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingStoredResume = false);
    }
  }

  /// Renders the current CV Builder data to PDF and uploads it to the
  /// `resumes` bucket, replacing any previously stored resume.
  Future<void> _generateAndUploadResume() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      AuthBottomSheet.show(
        context,
        title: 'Authentication Required',
        actionText: 'Unlock Resume Upload',
        onSuccess: _generateAndUploadResume,
      );
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    setState(() => _isUploadingResume = true);
    try {
      final url = await _resumeFileService.generateAndUpload(provider, colorScheme.primary, colorScheme.secondary);
      if (!mounted) return;
      setState(() {
        _storedResumeUrl = url;
        _isUploadingResume = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume compiled and uploaded.'), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingResume = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload resume. Please try again.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _removeStoredResume() async {
    setState(() => _isUploadingResume = true);
    try {
      await _resumeFileService.deleteStoredResume();
      if (!mounted) return;
      setState(() {
        _storedResumeUrl = null;
        _isUploadingResume = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume removed.'), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingResume = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove resume.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _openStoredResume() async {
    final url = _storedResumeUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the resume file.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _syncControllersFromProvider(DashboardProvider provider) {
    if (_controllersSynced) return;
    _nameController.text = provider.resumeName;
    _titleController.text = provider.resumeTitle;
    _emailController.text = provider.resumeEmail;
    _phoneController.text = provider.resumePhone;
    _summaryController.text = provider.resumeSummary;
    _controllersSynced = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    _newSectionTitleController.dispose();
    _newRoleController.dispose();
    _newCompanyController.dispose();
    _newPeriodController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      Provider.of<DashboardProvider>(context, listen: false).updateResumeDetails(
        name: _nameController.text,
        title: _titleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        summary: _summaryController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CV details saved dynamically!'),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddSectionDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New CV Section', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose from recommended sections:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestedSections.map((secName) {
                    final exists = provider.customSections.any((sec) => sec.title.toLowerCase() == secName.toLowerCase());
                    return ActionChip(
                      label: Text(secName),
                      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: exists ? Colors.grey : colorScheme.secondary),
                      backgroundColor: exists ? Colors.grey.withOpacity(0.1) : colorScheme.secondary.withOpacity(0.08),
                      side: BorderSide(color: exists ? Colors.transparent : colorScheme.secondary.withOpacity(0.2)),
                      onPressed: exists 
                          ? null 
                          : () {
                              provider.addCustomSection(secName);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added section: $secName'), behavior: SnackBarBehavior.floating),
                              );
                            },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Or type a custom section name:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                TextField(
                  controller: _newSectionTitleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Patent Filings, Extracurriculars...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _newSectionTitleController.text.trim();
                if (text.isNotEmpty) {
                  provider.addCustomSection(text);
                  _newSectionTitleController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added section: $text'), behavior: SnackBarBehavior.floating),
                  );
                }
              },
              child: const Text('Add Custom Section'),
            ),
          ],
        );
      },
    );
  }

  void _addNewRole() {
    final role = _newRoleController.text.trim();
    final company = _newCompanyController.text.trim();
    final period = _newPeriodController.text.trim();

    if (role.isNotEmpty && company.isNotEmpty) {
      Provider.of<DashboardProvider>(context, listen: false).addExperience(role, company, period);
      _newRoleController.clear();
      _newCompanyController.clear();
      _newPeriodController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Work Experience Role added! Add responsibilities below.'), behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Role Title and Company Name.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;

    if (provider.isLoadingResume) {
      return Scaffold(
        appBar: AppBar(title: const Text('CV / Resume Builder')),
        body: Center(child: CircularProgressIndicator(color: colorScheme.secondary)),
      );
    }

    if (provider.resumeError != null && provider.templates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('CV / Resume Builder')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.primary.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(provider.resumeError!, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF64748B))),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: provider.loadResumeData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    _syncControllersFromProvider(provider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('CV / Resume Builder'),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Export PDF'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return FutureBuilder<String>(
                    future: CvExporter().saveCvFile(provider, colorScheme.primary, colorScheme.secondary),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return AlertDialog(
                          content: Row(
                            children: [
                              CircularProgressIndicator(color: colorScheme.secondary),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  'Compiling PDF with template and saving to Downloads...',
                                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final resultText = snapshot.data ?? 'Error exporting file.';
                      final success = snapshot.hasData && !snapshot.hasError;

                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              success ? Icons.check_circle_rounded : Icons.error_rounded,
                              color: success ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(success ? 'Export Successful' : 'Export Failed'),
                          ],
                        ),
                        content: Text(resultText, style: const TextStyle(fontSize: 13, height: 1.4)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Done', style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Column: Edit Form
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUploadedResumeCard(context, colorScheme),
                    const SizedBox(height: 32),
                    Text(
                      'Choose Your Design Template',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.templates.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final template = provider.templates[index];
                          final isSelected = provider.selectedTemplateIndex == index;
                          return InkWell(
                            onTap: () => provider.selectTemplate(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 170,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? colorScheme.secondary : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: colorScheme.secondary.withOpacity(0.15), blurRadius: 8)]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    template.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.primary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template.complexity,
                                    style: TextStyle(
                                      color: isSelected ? colorScheme.secondary : const Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template.description,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      'Personal Details',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_rounded,
                      onChanged: (val) => provider.updateResumeDetails(name: val),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _titleController,
                      label: 'Professional Title',
                      hint: 'Senior Software Engineer',
                      icon: Icons.work_rounded,
                      onChanged: (val) => provider.updateResumeDetails(title: val),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'john.doe@exertly.io',
                            icon: Icons.email_rounded,
                            onChanged: (val) => provider.updateResumeDetails(email: val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: '+1 (555) 019-2834',
                            icon: Icons.phone_rounded,
                            onChanged: (val) => provider.updateResumeDetails(phone: val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _summaryController,
                      label: 'Professional Summary',
                      hint: 'Brief summary of your background and core skills...',
                      icon: Icons.description_rounded,
                      maxLines: 4,
                      onChanged: (val) => provider.updateResumeDetails(summary: val),
                    ),

                    const SizedBox(height: 32),
                    // Skills Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Core Skills',
                          style: theme.textTheme.titleLarge,
                        ),
                        const Text('Click to remove', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillController,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              hintText: 'Add new skill (e.g. Flutter, Rust)...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onSubmitted: (val) {
                              provider.addSkill(val);
                              _skillController.clear();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: () {
                            provider.addSkill(_skillController.text);
                            _skillController.clear();
                          },
                          icon: const Icon(Icons.add_rounded),
                          style: IconButton.styleFrom(backgroundColor: colorScheme.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: provider.resumeSkills.map((skill) {
                        return InputChip(
                          label: Text(skill),
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          onDeleted: () => provider.removeSkill(skill),
                          deleteIconColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: colorScheme.secondary.withOpacity(0.08),
                          side: BorderSide(color: colorScheme.secondary.withOpacity(0.2)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    // Work Experience section
                    Text(
                      'Work Experience',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Box form to add a NEW Role
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add New Work Position:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newRoleController,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  decoration: const InputDecoration(
                                    labelText: 'Role / Position',
                                    hintText: 'e.g. Senior Software Engineer',
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _newCompanyController,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  decoration: const InputDecoration(
                                    labelText: 'Company',
                                    hintText: 'e.g. Stripe',
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newPeriodController,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  decoration: const InputDecoration(
                                    labelText: 'Period / Duration',
                                    hintText: 'e.g. 2024 - Present',
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _addNewRole,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                                child: const Text('Add Role Card'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Render dynamic Roles & Responsibilities list
                    if (provider.resumeExperience.isNotEmpty) ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.resumeExperience.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final exp = provider.resumeExperience[index];
                          return _WorkExperienceEditorCard(
                            key: ValueKey(exp.id),
                            exp: exp,
                            onAddResp: (resp) => provider.addResponsibilityToExperience(exp.id, resp),
                            onRemoveResp: (respIndex) => provider.removeResponsibilityFromExperience(exp.id, respIndex),
                            onDeleteRole: () => provider.removeExperience(exp.id),
                          );
                        },
                      ),
                    ],

                    // Dynamic Custom Sections Editor cards
                    if (provider.customSections.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        'Additional Sections',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.customSections.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final sec = provider.customSections[index];
                          return _CustomSectionEditorCard(
                            key: ValueKey(sec.id),
                            sec: sec,
                            onAddItem: (item) => provider.addItemToSection(sec.id, item),
                            onRemoveItem: (itemIndex) => provider.removeItemFromSection(sec.id, itemIndex),
                            onDeleteSection: () => provider.removeCustomSection(sec.id),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 32),
                    
                    // Add Section Trigger Dropdown button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Add Custom Section (Awards, Languages, etc.)', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.secondary,
                          side: BorderSide(color: colorScheme.secondary, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _showAddSectionDialog,
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save Details Dynamically'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Right Column: Realistic Live CV Sheet Preview (Desktop Only for visual aesthetics)
          if (isDesktop)
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFFE2E8F0),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: _buildLiveResumeSheet(provider),
                ),
              ),
            ),
        ],
      ),
      // Mobile floating action button for Preview
      floatingActionButton: !isDesktop
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFFE2E8F0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: Scaffold(
                        backgroundColor: const Color(0xFFE2E8F0),
                        appBar: AppBar(
                          title: const Text('Live CV Preview'),
                          backgroundColor: colorScheme.primary,
                        ),
                        body: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: _buildLiveResumeSheet(provider),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('Live Preview'),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildLiveResumeSheet(DashboardProvider provider) {
    final selectedTemplate = provider.templates[provider.selectedTemplateIndex];
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Choose styling accents based on selected template inside the professional Letter Sheet
    Color accentColor = colorScheme.primary; // Dynamic Theme Primary
    Color secondaryAccent = colorScheme.secondary; // Dynamic Theme Secondary
    bool creativeLayout = false;

    if (selectedTemplate.id == '2') {
      accentColor = colorScheme.primary; // Dynamic Theme Primary
      secondaryAccent = colorScheme.secondary; // Dynamic Theme Secondary
      creativeLayout = true;
    } else if (selectedTemplate.id == '3') {
      accentColor = Colors.grey[800]!; // Charcoal
      secondaryAccent = Colors.grey[600]!;
    }

    Widget content = Container(
      width: 595, // Standard US Letter/A4 aspect width
      constraints: const BoxConstraints(minHeight: 842), // Aspect Height
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(4),
      ),
      child: creativeLayout 
          ? _buildCreativeLayout(provider, accentColor, secondaryAccent) 
          : _buildClassicLayout(provider, accentColor, secondaryAccent),
    );

    return content;
  }

  Widget _buildClassicLayout(DashboardProvider provider, Color accent, Color secondaryAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & Header
        Center(
          child: Column(
            children: [
              Text(
                provider.resumeName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.resumeTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: secondaryAccent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${provider.resumeEmail}   |   ${provider.resumePhone}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Divider(color: accent, thickness: 1.5),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Summary
        _buildCvSectionHeader('PROFESSIONAL SUMMARY', accent),
        const SizedBox(height: 8),
        Text(
          provider.resumeSummary,
          style: const TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 24),

        // Dynamic Experience Roles & Responsibilities list (Classic)
        _buildCvSectionHeader('PROFESSIONAL EXPERIENCE', accent),
        const SizedBox(height: 12),
        ...provider.resumeExperience.map((exp) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      exp.role,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      exp.period,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  exp.company,
                  style: TextStyle(fontSize: 11, color: secondaryAccent, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                
                // Render Dynamic responsibilities as bullet points
                if (exp.responsibilities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text('No responsibilities added yet.', style: TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                  )
                else
                  ...exp.responsibilities.map((resp) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•  ', style: TextStyle(color: secondaryAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              resp,
                              style: const TextStyle(fontSize: 9.5, height: 1.35, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 12),

        // Skills
        _buildCvSectionHeader('TECHNICAL & CORE SKILLS', accent),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: provider.resumeSkills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                skill,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            );
          }).toList(),
        ),
        
        // Render Dynamic Custom Sections (Bulleted Points)
        ...provider.customSections.map((sec) {
          if (sec.items.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildCvSectionHeader(sec.title.toUpperCase(), accent),
              const SizedBox(height: 8),
              ...sec.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: TextStyle(color: secondaryAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 10, height: 1.3, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCreativeLayout(DashboardProvider provider, Color accent, Color secondaryAccent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar (1/3 width)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: secondaryAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  provider.resumeName.isNotEmpty ? provider.resumeName[0] : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                provider.resumeName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent),
              ),
              Text(
                provider.resumeTitle,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: secondaryAccent),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              const Text('CONTACT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              Text(provider.resumeEmail, style: const TextStyle(fontSize: 9, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(provider.resumePhone, style: const TextStyle(fontSize: 9, color: Color(0xFF1E293B))),
              const SizedBox(height: 24),
              const Text('TECHNICAL SKILLS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: provider.resumeSkills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Main Body (2/3 width)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCvSectionHeader('PROFESSIONAL PROFILE', accent),
              const SizedBox(height: 8),
              Text(
                provider.resumeSummary,
                style: const TextStyle(fontSize: 10.5, height: 1.4, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 28),
              _buildCvSectionHeader('WORK HISTORY', accent),
              const SizedBox(height: 12),
              
              // Render Dynamic Experience Roles & Responsibilities list (Creative)
              ...provider.resumeExperience.map((exp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              exp.role,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Text(
                            exp.period,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      Text(
                        exp.company,
                        style: TextStyle(fontSize: 10, color: secondaryAccent, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      
                      // Bullet responsibilities
                      if (exp.responsibilities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('No responsibilities added yet.', style: TextStyle(fontSize: 8.5, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                        )
                      else
                        ...exp.responsibilities.map((resp) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('•  ', style: TextStyle(color: secondaryAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    resp,
                                    style: const TextStyle(fontSize: 9, height: 1.3, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                );
              }).toList(),

              // Render Dynamic Custom Sections in Creative Layout
              ...provider.customSections.map((sec) {
                if (sec.items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildCvSectionHeader(sec.title.toUpperCase(), accent),
                    const SizedBox(height: 8),
                    ...sec.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•  ', style: TextStyle(color: secondaryAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 9, height: 1.3, color: Color(0xFF1E293B)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedResumeCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file_rounded, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cloud Resume',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Compile your CV Builder details into a PDF and store it in the cloud, so you always have an up-to-date resume ready to share.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 16),
          if (_isLoadingStoredResume)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_storedResumeUrl != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_rounded, color: colorScheme.secondary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'resume.pdf',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    tooltip: 'View resume',
                    color: colorScheme.primary,
                    onPressed: _isUploadingResume ? null : _openStoredResume,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    tooltip: 'Remove resume',
                    color: Colors.redAccent,
                    onPressed: _isUploadingResume ? null : _removeStoredResume,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUploadingResume ? null : _generateAndUploadResume,
              icon: _isUploadingResume
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 18),
              label: Text(_storedResumeUrl != null ? 'Regenerate & Upload' : 'Generate & Upload Resume'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                side: BorderSide(color: colorScheme.secondary.withOpacity(0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvSectionHeader(String title, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          width: double.infinity,
          color: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please fill in this field';
        }
        return null;
      },
    );
  }
}

// Inner Widget: Custom Section Editor Card with self-contained text controller
class _CustomSectionEditorCard extends StatefulWidget {
  final CustomSection sec;
  final Function(String) onAddItem;
  final Function(int) onRemoveItem;
  final VoidCallback onDeleteSection;

  const _CustomSectionEditorCard({
    super.key,
    required this.sec,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onDeleteSection,
  });

  @override
  State<_CustomSectionEditorCard> createState() => _CustomSectionEditorCardState();
}

class _CustomSectionEditorCardState extends State<_CustomSectionEditorCard> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star_outline_rounded, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.sec.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                tooltip: 'Delete Section',
                onPressed: widget.onDeleteSection,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Add bullet point to ${widget.sec.title}...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      widget.onAddItem(val);
                      _itemController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  final text = _itemController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onAddItem(text);
                    _itemController.clear();
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                style: IconButton.styleFrom(backgroundColor: colorScheme.secondary),
              ),
            ],
          ),
          if (widget.sec.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.sec.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = widget.sec.items[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: colorScheme.secondary, size: 14),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => widget.onRemoveItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// Inner Widget: Work Experience Role Editor Card (with self-contained dynamic responsibility controller)
class _WorkExperienceEditorCard extends StatefulWidget {
  final WorkExperience exp;
  final Function(String) onAddResp;
  final Function(int) onRemoveResp;
  final VoidCallback onDeleteRole;

  const _WorkExperienceEditorCard({
    super.key,
    required this.exp,
    required this.onAddResp,
    required this.onRemoveResp,
    required this.onDeleteRole,
  });

  @override
  State<_WorkExperienceEditorCard> createState() => _WorkExperienceEditorCardState();
}

class _WorkExperienceEditorCardState extends State<_WorkExperienceEditorCard> {
  final TextEditingController _respController = TextEditingController();

  @override
  void dispose() {
    _respController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.exp.role} at ${widget.exp.company}',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                    ),
                    Text(
                      widget.exp.period,
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                tooltip: 'Delete Role Position',
                onPressed: widget.onDeleteRole,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _respController,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Add responsibility / bullet for this role...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      widget.onAddResp(val);
                      _respController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  final text = _respController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onAddResp(text);
                    _respController.clear();
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                style: IconButton.styleFrom(backgroundColor: colorScheme.secondary),
              ),
            ],
          ),
          if (widget.exp.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.exp.responsibilities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final resp = widget.exp.responsibilities[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_rounded, color: colorScheme.secondary, size: 14),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          resp,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => widget.onRemoveResp(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
