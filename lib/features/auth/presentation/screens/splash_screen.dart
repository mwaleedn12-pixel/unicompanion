import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    // Give animations time to play before navigating
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;

    // Not logged in
    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    // Logged in — check onboarding from Supabase
    try {
      final data = await Supabase.instance.client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (data != null && data['onboarding_completed'] == true) {
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.onboarding);
      }
    } catch (_) {
      if (mounted) context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A3EB1), AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Logo icon ── scale up + fade in
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 50),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // ── App name ── slide up + fade in (delayed)
              Text(
                'UniCompanion',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              )
                  .animate(delay: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic)
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: 8),

              // ── Tagline ── fade in with shimmer
              Text(
                'Your Academic Journey, Simplified',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 500.ms)
                  .shimmer(
                    delay: 1200.ms,
                    duration: 1800.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),

              const SizedBox(height: 40),

              // ── Loading dots ── fade in late + gentle pulse
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(
                        delay: (900 + i * 150).ms,
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}