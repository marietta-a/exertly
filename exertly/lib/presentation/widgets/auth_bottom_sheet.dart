import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AuthBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final String title;
  final String actionText;

  const AuthBottomSheet({
    super.key,
    required this.onSuccess,
    this.title = 'Authentication Required',
    this.actionText = 'Unlock Feature',
  });

  static void show(
    BuildContext context, {
    required VoidCallback onSuccess,
    String title = 'Authentication Required',
    String actionText = 'Unlock Feature',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthBottomSheet(
        onSuccess: onSuccess,
        title: title,
        actionText: actionText,
      ),
    );
  }

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  bool get _isLoading => _isLoadingEmail || _isLoadingGoogle || _isLoadingApple;

  void _onAuthSuccess() {
    Navigator.pop(context);
    widget.onSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 12),
            Text('Authentication successful! Feature unlocked.'),
          ],
        ),
        backgroundColor: AppTheme.darkBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Sign-in failed. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _isLoadingEmail = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = _isSignUpMode
        ? await authProvider.signUpWithEmail(email, _passwordController.text)
        : await authProvider.signInWithEmail(email, _passwordController.text);

    if (!mounted) return;
    setState(() => _isLoadingEmail = false);

    if (!success) {
      _showError(authProvider.errorMessage);
      return;
    }

    if (_isSignUpMode && !authProvider.isAuthenticated) {
      final router = GoRouter.of(context);
      Navigator.pop(context);
      router.push('/confirm-email', extra: email);
      return;
    }

    _onAuthSuccess();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoadingGoogle = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoadingGoogle = false);
    if (!success) {
      _showError(authProvider.errorMessage);
      return;
    }
    _onAuthSuccess();
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoadingApple = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithApple();
    if (!mounted) return;
    setState(() => _isLoadingApple = false);
    if (!success) {
      _showError(authProvider.errorMessage);
      return;
    }
    _onAuthSuccess();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.crispWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 28,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded, color: AppTheme.accentOrange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.darkBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _isSignUpMode
                    ? 'Create an account to authenticate and unlock full interactive privileges on this module.'
                    : 'Sign in to authenticate and unlock full interactive privileges on this module.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'name@exertly.io',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.darkBlue, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty || !val.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.darkBlue, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailAuth,
                  child: _isLoadingEmail
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: AppTheme.crispWhite, strokeWidth: 2.5),
                        )
                      : Text(_isSignUpMode ? 'Create Account' : widget.actionText),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _isSignUpMode = !_isSignUpMode),
                  child: Text(
                    _isSignUpMode ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                    style: const TextStyle(color: AppTheme.darkBlue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.borderGray)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: AppTheme.borderGray)),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.crispWhite,
                    side: const BorderSide(color: AppTheme.borderGray),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoadingGoogle
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.darkBlue),
                        )
                      : const FaIcon(FontAwesomeIcons.google, size: 18, color: AppTheme.darkBlue),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleAppleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.black.withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoadingApple
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const FaIcon(FontAwesomeIcons.apple, size: 20, color: Colors.white),
                  label: const Text(
                    'Continue with Apple',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
