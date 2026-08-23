import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileState.when(
          initial: () => const AppLoadingIndicator(),
          loading: () => const AppLoadingIndicator(),
          error: (msg) => AppErrorView(message: msg),
          success: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          profile.firstNameGreeting[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile.fullName.isNotEmpty ? profile.fullName : 'Student',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profile.isFscStudent ? 'FSC Student' : 'University Student',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (profile.isFscStudent && (profile.matricPercentage != null || profile.fscPercentage != null)) ...[
                  _SectionTitle(title: 'Academic Info'),
                  const SizedBox(height: 10),
                  if (profile.matricPercentage != null)
                    _InfoTile(icon: Icons.school_outlined, label: 'Matric', value: '${profile.matricPercentage!.toStringAsFixed(1)}%', color: AppColors.secondary),
                  if (profile.fscPercentage != null)
                    _InfoTile(icon: Icons.menu_book_rounded, label: 'FSC', value: '${profile.fscPercentage!.toStringAsFixed(1)}%', color: AppColors.primary),
                  if (profile.fscStream != null)
                    _InfoTile(icon: Icons.category_rounded, label: 'Stream', value: profile.fscStream!.replaceAll('_', ' ').toUpperCase(), color: AppColors.accent),
                  const SizedBox(height: 24),
                ],

                if (profile.isUniversityStudent) ...[
                  _SectionTitle(title: 'University Info'),
                  const SizedBox(height: 10),
                  if (profile.currentSemester != null)
                    _InfoTile(icon: Icons.calendar_month_rounded, label: 'Semester', value: '${profile.currentSemester}', color: AppColors.primary),
                  if (profile.enrollmentYear != null)
                    _InfoTile(icon: Icons.date_range_rounded, label: 'Enrolled', value: '${profile.enrollmentYear}', color: AppColors.secondary),
                  const SizedBox(height: 24),
                ],

                if (profile.careerInterests.isNotEmpty) ...[
                  _SectionTitle(title: 'Career Interests'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.careerInterests.map((i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
                      child: Text(i, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryDark)),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                _SectionTitle(title: 'Settings'),
                const SizedBox(height: 10),

                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  color: AppColors.info,
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Deadline Reminders',
                  color: AppColors.accent,
                  trailing: Switch(
                    value: ref.watch(remindersEnabledProvider),
                    onChanged: (value) async {
                      await ref.read(remindersEnabledProvider.notifier).setEnabled(value);
                      if (!context.mounted) return;
                      final nowEnabled = ref.read(remindersEnabledProvider);
                      if (value && !nowEnabled) {
                        context.showSnackBar('Notification permission denied — enable it in system settings.');
                      } else {
                        context.showSnackBar(nowEnabled ? 'Deadline reminders on' : 'Deadline reminders off');
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.edit_rounded,
                  title: 'Edit Profile',
                  color: AppColors.secondary,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiaryLight),
                  onTap: () => context.showSnackBar('Coming soon!'),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.refresh_rounded,
                  title: 'Redo Onboarding',
                  color: AppColors.accent,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiaryLight),
                  onTap: () async {
                    await LocalStorageService.setOnboardingComplete(false);
                    if (context.mounted) context.go(RouteNames.onboarding);
                  },
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About UniCompanion',
                  color: AppColors.primary,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiaryLight),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'UniCompanion',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'FSC to Graduation — Your Academic Companion',
                    );
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.error),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref.read(profileActionProvider.notifier).signOut();
                        if (context.mounted) context.go(RouteNames.splash);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, required this.color, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
            trailing,
          ],
        ),
      ),
    );
  }
}