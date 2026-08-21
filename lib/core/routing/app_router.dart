import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import 'app_shell.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/screens/university_detail_screen.dart';
import '../../features/tools/presentation/screens/tools_screen.dart';
import '../../features/tools/presentation/screens/gpa_calculator_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: RouteNames.splash, name: 'splash', builder: (context, state) => const SplashScreen()),
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
            GoRoute(
              path: RouteNames.explore,
              name: 'explore',
              builder: (context, state) => const ExploreScreen(),
              routes: [
                GoRoute(
                  path: 'university/:id',
                  name: 'university-detail',
                  builder: (context, state) => UniversityDetailScreen(universityId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.tools,
              name: 'tools',
              builder: (context, state) => const ToolsScreen(),
              routes: [
                GoRoute(path: 'gpa', name: 'gpa-calculator', builder: (context, state) => const GpaCalculatorScreen()),
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