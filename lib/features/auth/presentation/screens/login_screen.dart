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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authStateProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  void _handleGoogleLogin() {
    ref.read(authStateProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (prev, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (_) => context.go(RouteNames.home),
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
                  title: 'Welcome Back',
                  subtitle: 'Sign in to continue your journey',
                ),

                // Google Sign-In
                GoogleSignInButton(
                  onPressed: _handleGoogleLogin,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: AppSpacing.xl),
                const OrDivider(),
                const SizedBox(height: AppSpacing.xl),

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
                const SizedBox(height: AppSpacing.sm),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Login Button
                PrimaryButton(
                  text: 'Sign In',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        'Sign Up',
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