import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Social sign-in button (Google)
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        child: isLoading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    height: 20,
                    width: 20,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Continue with Google', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
      ),
    );
  }
}

/// Divider with "or" text
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text('or', style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
      ],
    );
  }
}

/// Password field with show/hide toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

/// App logo/header for auth screens
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        // App icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}