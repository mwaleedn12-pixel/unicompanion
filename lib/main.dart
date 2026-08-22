import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await LocalStorageService.init();

  // Sync onboarding status from Supabase BEFORE app starts
  await _syncOnboardingFromSupabase();

  runApp(const ProviderScope(child: UniCompanionApp()));
}

/// Always re-syncs local cache from Supabase for the currently authenticated
/// user on every cold start / page reload. This intentionally does NOT trust
/// the local cache first — a browser reload can be a different account than
/// whichever one last wrote to local storage (e.g. testing multiple accounts).
Future<void> _syncOnboardingFromSupabase() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  try {
    final data = await Supabase.instance.client
        .from('user_profiles')
        .select('onboarding_completed, user_type')
        .eq('id', user.id)
        .maybeSingle();

    final isComplete = data != null && data['onboarding_completed'] == true;
    await LocalStorageService.setOnboardingComplete(isComplete);

    if (isComplete && data['user_type'] != null) {
      await LocalStorageService.setUserType(data['user_type']);
    } else {
      await LocalStorageService.clearUserType();
    }
  } catch (_) {}
}

class UniCompanionApp extends ConsumerWidget {
  const UniCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'UniCompanion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}