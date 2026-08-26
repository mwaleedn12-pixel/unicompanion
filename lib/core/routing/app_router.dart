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
import '../../features/explore/presentation/screens/programs_explorer_screen.dart';
import '../../features/explore/presentation/screens/campus_screen.dart';
import '../../features/explore/presentation/screens/university_reviews_screen.dart'; // #2
import '../../features/tools/presentation/screens/tools_screen.dart';
import '../../features/tools/presentation/screens/gpa_calculator_screen.dart';
import '../../features/tools/presentation/screens/cgpa_calculator_screen.dart';
import '../../features/tools/presentation/screens/attendance_calculator_screen.dart';
import '../../features/tools/presentation/screens/target_gpa_screen.dart';
import '../../features/tools/presentation/screens/merit_calculator_screen.dart';
import '../../features/tools/presentation/screens/eligibility_checker_screen.dart';
import '../../features/tools/presentation/screens/grade_calculator_screen.dart';
import '../../features/tools/presentation/screens/fee_comparison_screen.dart'; // #3
import '../../features/tools/presentation/screens/admission_probability_screen.dart'; // #5
import '../../features/track/presentation/screens/track_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/academics/presentation/screens/semester_manager_screen.dart';
import '../../features/academics/presentation/screens/assignment_tracker_screen.dart';
import '../../features/academics/presentation/screens/academic_dashboard_screen.dart';
import '../../features/applications/presentation/screens/shortlist_screen.dart';
import '../../features/applications/presentation/screens/application_tracker_screen.dart';
import '../../features/test_prep/presentation/screens/test_prep_screen.dart';
import '../../features/tools/presentation/screens/university_match_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/community/presentation/screens/discussions_screen.dart';
import '../../features/parent/presentation/screens/parent_mode_screen.dart';

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

      // Standalone routes (pushed, not go'd — so back button works)
      GoRoute(path: '/scholarships', name: 'scholarships', builder: (context, state) => const ScholarshipScreen()),
      GoRoute(path: '/career-quiz', name: 'career-quiz', builder: (context, state) => const CareerQuizScreen()),
      GoRoute(path: '/programs', name: 'programs-explorer', builder: (context, state) => const ProgramsExplorerScreen()),
      GoRoute(path: '/campuses', name: 'campus-profiles', builder: (context, state) => const CampusScreen()),
      GoRoute(path: RouteNames.aiAssistant, name: 'ai-assistant', builder: (context, state) => const AiAssistantScreen()),
      GoRoute(path: RouteNames.jobs, name: 'jobs', builder: (context, state) => const JobsScreen()),
      GoRoute(path: RouteNames.community, name: 'community', builder: (context, state) => const DiscussionsScreen()),
      GoRoute(path: RouteNames.parentMode, name: 'parent-mode', builder: (context, state) => const ParentModeScreen()),

      // #2 — University Reviews
      GoRoute(
        path: '/reviews/:id',
        name: 'reviews',
        builder: (context, state) => UniversityReviewsScreen(
          universityId: state.pathParameters['id']!,
          universityName: state.uri.queryParameters['name'] ?? '',
        ),
      ),

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
                GoRoute(path: 'test-prep', name: 'test-prep', builder: (context, state) => const TestPrepScreen()),
                GoRoute(path: 'match', name: 'university-match', builder: (context, state) => const UniversityMatchScreen()),
                GoRoute(path: 'fee-compare', name: 'fee-compare', builder: (context, state) => const FeeComparisonScreen()), // #3
                GoRoute(path: 'probability', name: 'admission-probability', builder: (context, state) => const AdmissionProbabilityScreen()), // #5
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
                GoRoute(path: RouteNames.shortlist, name: 'shortlist', builder: (context, state) => const ShortlistScreen()),
                GoRoute(path: RouteNames.applicationTracker, name: 'application-tracker', builder: (context, state) => const ApplicationTrackerScreen()),
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