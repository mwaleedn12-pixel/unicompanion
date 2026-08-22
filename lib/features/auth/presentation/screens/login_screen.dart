import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
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
        success: (_) {
          final onboardingComplete = ref.read(authStateProvider.notifier).onboardingComplete;
          context.go(onboardingComplete ? RouteNames.home : RouteNames.onboarding);
        },
        error: (msg) => context.showSnackBar(msg, isError: true),
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primarySurface, Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // Logo & Title
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'UniCompanion',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your academic journey starts here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Card container for form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to your account',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppColors.textTertiaryLight),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        PasswordField(
                          controller: _passwordController,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push(RouteNames.forgotPassword),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Text('Forgot Password?', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login Button
                        PrimaryButton(
                          text: 'Sign In',
                          isLoading: authState.isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const OrDivider(),
                  const SizedBox(height: 24),

                  // Google Sign-In
                  GoogleSignInButton(
                    onPressed: _handleGoogleLogin,
                    isLoading: authState.isLoading,
                  ),

                  const SizedBox(height: 32),

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
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}