import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import 'route_names.dart';
import 'app_shell.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.forgotPassword;
      final isOnboarding = state.matchedLocation == RouteNames.onboarding;

      // Not logged in → go to login
      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;

      // Logged in but on auth page → check onboarding
      if (isLoggedIn && isAuthRoute) {
        final onboardingDone = LocalStorageService.isOnboardingComplete;
        return onboardingDone ? RouteNames.home : RouteNames.onboarding;
      }

      // Logged in, not on auth, check onboarding
      if (isLoggedIn && !isOnboarding && !LocalStorageService.isOnboardingComplete) {
        return RouteNames.onboarding;
      }

      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: RouteNames.register, name: 'register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: RouteNames.forgotPassword, name: 'forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: RouteNames.onboarding, name: 'onboarding', builder: (context, state) => const OnboardingScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.home, name: 'home', builder: (context, state) => const _PlaceholderScreen(title: 'Home')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.explore, name: 'explore', builder: (context, state) => const _PlaceholderScreen(title: 'Explore')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.tools, name: 'tools', builder: (context, state) => const _PlaceholderScreen(title: 'Tools')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.track, name: 'track', builder: (context, state) => const _PlaceholderScreen(title: 'Track')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.profile, name: 'profile', builder: (context, state) => const _PlaceholderScreen(title: 'Profile')),
          ]),
        ],
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}