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

/// If user is logged in but local storage is empty (e.g. web refresh),
/// check Supabase for onboarding status
Future<void> _syncOnboardingFromSupabase() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;
  if (LocalStorageService.isOnboardingComplete) return;

  try {
    final data = await Supabase.instance.client
        .from('user_profiles')
        .select('onboarding_completed, user_type')
        .eq('id', user.id)
        .maybeSingle();

    if (data != null && data['onboarding_completed'] == true) {
      await LocalStorageService.setOnboardingComplete(true);
      if (data['user_type'] != null) {
        await LocalStorageService.setUserType(data['user_type']);
      }
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