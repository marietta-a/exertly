import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  bool get _isLoading => _isLoadingEmail || _isLoadingGoogle || _isLoadingApple;

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
      // Supabase project requires email confirmation before a session is issued.
      context.push('/confirm-email', extra: email);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoadingGoogle = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoadingGoogle = false);
    if (!success) _showError(authProvider.errorMessage);
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoadingApple = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithApple();
    if (!mounted) return;
    setState(() => _isLoadingApple = false);
    if (!success) _showError(authProvider.errorMessage);
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Sign-in failed. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    return Scaffold(
      backgroundColor: AppTheme.lightBlueBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: isDesktop
                ? BoxDecoration(
                    color: AppTheme.crispWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderGray),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkBlue.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  )
                : null,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Branding
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: AppTheme.crispWhite,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Exertly',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.darkBlue,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Intro
                  Text(
                    _isSignUpMode ? 'Create your account' : 'Welcome back',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to build resumes, search jobs, and locate scholarships.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'name@company.com',
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
                  const SizedBox(height: 16),

                  // Password
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
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        disabledBackgroundColor: AppTheme.accentOrange.withOpacity(0.6),
                      ),
                      child: _isLoadingEmail
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppTheme.crispWhite,
                              ),
                            )
                          : Text(
                              _isSignUpMode ? 'Create Account' : 'Sign In',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Toggle Sign In / Sign Up
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _isSignUpMode = !_isSignUpMode),
                      child: Text(
                        _isSignUpMode
                            ? 'Already have an account? Sign In'
                            : "Don't have an account? Sign Up",
                        style: const TextStyle(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.borderGray)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: AppTheme.borderGray)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-In
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Apple Sign-In
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Continue as Guest Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Bottom Info Panel
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentOrange.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_rounded, color: AppTheme.accentOrange, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sign-in is powered by Supabase Auth. Google and Apple sign-in are being finalized — you may see a provider error until they’re fully configured.',
                            style: TextStyle(fontSize: 11, color: AppTheme.accentOrange, height: 1.3, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
