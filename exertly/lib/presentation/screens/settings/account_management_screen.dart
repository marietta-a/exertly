import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../services/supabase/avatar_service.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final _avatarService = AvatarService();
  bool _isUploadingAvatar = false;

  bool _controllersSynced = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  void _syncControllersFromProvider(DashboardProvider provider) {
    if (_controllersSynced) return;
    _nameController.text = provider.resumeName;
    _titleController.text = provider.resumeTitle;
    _emailController.text = provider.resumeEmail;
    _phoneController.text = provider.resumePhone;
    _controllersSynced = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

      dashboardProvider.updateResumeDetails(
        name: _nameController.text,
        title: _titleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account details saved dynamically!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to upload a profile photo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picked = await _avatarService.pickAvatarImage();
    if (picked == null || !mounted) return;

    if (!_avatarService.isAllowedFile(picked)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a JPEG or PNG image.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploadingAvatar = true);
    try {
      final url = await _avatarService.compressAndUpload(picked);
      if (!mounted) return;
      await authProvider.updateAvatarUrl(url);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload photo. Please try a different image.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _removeAvatar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isUploadingAvatar = true);
    final ok = await authProvider.deleteAvatar();
    if (!mounted) return;
    setState(() => _isUploadingAvatar = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profile photo removed.' : 'Failed to remove photo.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAvatarPicker(AuthProvider authProvider, ColorScheme colorScheme) {
    final avatarUrl = authProvider.avatarUrl;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: colorScheme.secondary.withOpacity(0.1),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Icon(Icons.person_rounded, size: 48, color: colorScheme.secondary)
                : null,
          ),
          if (_isUploadingAvatar)
            Positioned.fill(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.black45,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: -4,
            right: -4,
            child: InkWell(
              onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
          if (avatarUrl != null)
            Positioned(
              bottom: -4,
              left: -4,
              child: InkWell(
                onTap: _isUploadingAvatar ? null : _removeAvatar,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (dashboardProvider.isLoadingResume) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Management')),
        body: Center(child: CircularProgressIndicator(color: colorScheme.secondary)),
      );
    }

    _syncControllersFromProvider(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatarPicker(authProvider, colorScheme),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.manage_accounts_rounded, color: colorScheme.secondary),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Edit Credentials',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!authProvider.isAuthenticated) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_person_rounded, color: colorScheme.secondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Browsing as a Guest. Changes made here will update the local session, but authenticate to enable full features.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      _buildFormTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildFormTextField(
                        controller: _titleController,
                        label: 'Professional Title',
                        icon: Icons.work_rounded,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_rounded,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_rounded,
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Profile Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Field cannot be empty';
        return null;
      },
    );
  }
}
