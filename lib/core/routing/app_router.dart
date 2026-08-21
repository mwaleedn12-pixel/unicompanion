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
import '../../features/home/presentation/screens/home_screen.dart';

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

      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
      if (isLoggedIn && isAuthRoute) {
        final onboardingDone = LocalStorageService.isOnboardingComplete;
        return onboardingDone ? RouteNames.home : RouteNames.onboarding;
      }
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
            GoRoute(path: RouteNames.home, name: 'home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.explore, name: 'explore', builder: (context, state) => const _PlaceholderScreen(title: 'Explore')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.tools,
              name: 'tools',
              builder: (context, state) => const _PlaceholderScreen(title: 'Tools'),
              routes: [
                GoRoute(path: 'gpa', name: 'gpa-calculator', builder: (context, state) => const _PlaceholderScreen(title: 'GPA Calculator')),
                GoRoute(path: 'cgpa', name: 'cgpa-calculator', builder: (context, state) => const _PlaceholderScreen(title: 'CGPA Calculator')),
                GoRoute(path: 'merit', name: 'merit-calculator', builder: (context, state) => const _PlaceholderScreen(title: 'Merit Calculator')),
                GoRoute(path: 'attendance', name: 'attendance-calculator', builder: (context, state) => const _PlaceholderScreen(title: 'Attendance')),
                GoRoute(path: 'target-gpa', name: 'target-gpa', builder: (context, state) => const _PlaceholderScreen(title: 'Target GPA')),
                GoRoute(path: 'eligibility', name: 'eligibility-checker', builder: (context, state) => const _PlaceholderScreen(title: 'Eligibility')),
              ],
            ),
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