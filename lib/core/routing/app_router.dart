import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/supabase_service.dart';
import 'route_names.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;

      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
      if (isLoggedIn && isAuthRoute) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const _PlaceholderScreen(title: 'Register'),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const _PlaceholderScreen(title: 'Onboarding'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.explore,
              name: 'explore',
              builder: (context, state) => const _PlaceholderScreen(title: 'Explore'),
            ),
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
                GoRoute(path: 'attendance', name: 'attendance-calculator', builder: (context, state) => const _PlaceholderScreen(title: 'Attendance Calculator')),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.track,
              name: 'track',
              builder: (context, state) => const _PlaceholderScreen(title: 'Track'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              name: 'profile',
              builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
            ),
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
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}