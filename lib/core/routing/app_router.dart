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
import '../../features/explore/presentation/screens/compare_screen.dart';
import '../../features/explore/presentation/screens/scholarship_screen.dart';
import '../../features/explore/presentation/screens/career_quiz_screen.dart';
import '../../features/explore/presentation/screens/programs_explorer_screen.dart'; // Module 27
import '../../features/explore/presentation/screens/campus_screen.dart'; // Module 29
import '../../features/tools/presentation/screens/tools_screen.dart';
import '../../features/tools/presentation/screens/gpa_calculator_screen.dart';
import '../../features/tools/presentation/screens/cgpa_calculator_screen.dart';
import '../../features/tools/presentation/screens/attendance_calculator_screen.dart';
import '../../features/tools/presentation/screens/target_gpa_screen.dart';
import '../../features/tools/presentation/screens/merit_calculator_screen.dart';
import '../../features/tools/presentation/screens/eligibility_checker_screen.dart';
import '../../features/tools/presentation/screens/grade_calculator_screen.dart';
import '../../features/track/presentation/screens/track_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/academics/presentation/screens/semester_manager_screen.dart';
import '../../features/academics/presentation/screens/assignment_tracker_screen.dart';
import '../../features/academics/presentation/screens/academic_dashboard_screen.dart';

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

      // Standalone routes (outside shell)
      GoRoute(path: '/scholarships', name: 'scholarships', builder: (context, state) => const ScholarshipScreen()),
      GoRoute(path: '/career-quiz', name: 'career-quiz', builder: (context, state) => const CareerQuizScreen()),
      GoRoute(path: '/programs', name: 'programs-explorer', builder: (context, state) => const ProgramsExplorerScreen()),
      GoRoute(path: '/campuses', name: 'campus-profiles', builder: (context, state) => const CampusScreen()),

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
                GoRoute(path: 'university/:id', name: 'university-detail', builder: (context, state) => UniversityDetailScreen(universityId: state.pathParameters['id']!)),
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
                GoRoute(path: 'cgpa', name: 'cgpa-calculator', builder: (context, state) => const CgpaCalculatorScreen()),
                GoRoute(path: 'attendance', name: 'attendance-calculator', builder: (context, state) => const AttendanceCalculatorScreen()),
                GoRoute(path: 'target-gpa', name: 'target-gpa', builder: (context, state) => const TargetGpaScreen()),
                GoRoute(path: 'merit', name: 'merit-calculator', builder: (context, state) => const MeritCalculatorScreen()),
                GoRoute(path: 'eligibility', name: 'eligibility-checker', builder: (context, state) => const EligibilityCheckerScreen()),
                GoRoute(path: 'grade', name: 'grade-calculator', builder: (context, state) => const GradeCalculatorScreen()),
                GoRoute(path: 'compare', name: 'compare', builder: (context, state) => const CompareScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.track,
              name: 'track',
              builder: (context, state) => const TrackScreen(),
              routes: [
                GoRoute(path: RouteNames.semesterManager, name: 'semester-manager', builder: (context, state) => const SemesterManagerScreen()),
                GoRoute(path: RouteNames.assignmentTracker, name: 'assignment-tracker', builder: (context, state) => const AssignmentTrackerScreen()),
                GoRoute(path: RouteNames.academicDashboard, name: 'academic-dashboard', builder: (context, state) => const AcademicDashboardScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.profile, name: 'profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});