import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(resetPasswordProvider.notifier).resetPassword(
          _emailController.text.trim(),
        );
    if (success) setState(() => _emailSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetPasswordProvider);

    ref.listen(resetPasswordProvider, (prev, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (_) {},
        error: (msg) => context.showSnackBar(msg, isError: true),
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: _emailSent ? _buildSuccessView(context) : _buildFormView(context, resetState),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context, dynamic resetState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Reset Password',
            subtitle: 'Enter your email and we\'ll send you a reset link',
          ),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            text: 'Send Reset Link',
            isLoading: resetState.isLoading,
            onPressed: _handleReset,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.massive),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Check Your Email', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          text: 'Back to Sign In',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}