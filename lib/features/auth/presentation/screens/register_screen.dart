import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authStateProvider.notifier).signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
  }

  void _handleGoogleSignIn() {
    ref.read(authStateProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (prev, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (_) {
          context.showSuccessSnackBar('Account created! Please verify your email.');
          context.go(RouteNames.home);
        },
        error: (msg) => context.showSnackBar(msg, isError: true),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Create Account',
                  subtitle: 'Start your academic journey today',
                ),

                // Google Sign-In
                GoogleSignInButton(
                  onPressed: _handleGoogleSignIn,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: AppSpacing.xl),
                const OrDivider(),
                const SizedBox(height: AppSpacing.xl),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, 'Full name'),
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: AppSpacing.base),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: AppSpacing.base),

                // Password
                PasswordField(
                  controller: _passwordController,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.base),

                // Confirm Password
                PasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  validator: (value) {
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return Validators.password(value);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Register Button
                PrimaryButton(
                  text: 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}