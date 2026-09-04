import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

/// Shown right after sign-up when the Supabase project requires confirming
/// the email address before a session is issued. Once the user taps the
/// confirmation link, Supabase's deep link redirect signs them in and the
/// router (see AppRouter) automatically navigates away from this screen.
class EmailConfirmationScreen extends StatefulWidget {
  final String? email;

  const EmailConfirmationScreen({super.key, this.email});

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isResending = false;

  Future<void> _handleResend() async {
    final email = widget.email;
    if (email == null) return;

    setState(() => _isResending = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendConfirmationEmail(email);

    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Confirmation email resent to $email.'
              : authProvider.errorMessage ?? 'Could not resend the email. Please try again.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;
    final email = widget.email;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    color: AppTheme.accentOrange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Check your email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                          height: 1.5,
                        ),
                    children: [
                      const TextSpan(text: "We've sent a confirmation link to "),
                      TextSpan(
                        text: email ?? 'your email address',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const TextSpan(
                        text: '. Click the link to activate your account, then come back and sign in.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (email != null)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isResending ? null : _handleResend,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderGray),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isResending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.darkBlue),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.darkBlue),
                      label: const Text(
                        'Resend confirmation email',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
