import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/shortlist_model.dart';
import '../providers/shortlist_provider.dart';
import '../providers/application_provider.dart';

class ShortlistScreen extends ConsumerWidget {
  const ShortlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shortlistProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('My Shortlist', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading shortlist...'),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.read(shortlistProvider.notifier).load()),
                success: (shortlist) {
                  if (shortlist.isEmpty) {
                    return AppEmptyView(
                      icon: Icons.bookmark_outline_rounded,
                      title: 'No Universities Shortlisted',
                      subtitle: 'Go to Explore and tap the bookmark icon on a university to save it here',
                      action: PrimaryButton(
                        text: 'Explore Universities',
                        icon: Icons.explore_outlined,
                        onPressed: () => context.go('/explore'),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: shortlist.length,
                    itemBuilder: (context, index) => _ShortlistCard(item: shortlist[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortlistCard extends ConsumerWidget {
  final ShortlistModel item;
  const _ShortlistCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = item.universityType == 'public' ? AppColors.primary : AppColors.secondary;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => ref.read(shortlistProvider.notifier).remove(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          onTap: () => context.push('/explore/university/${item.universityId}'),
          leading: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(item.initials, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14))),
          ),
          title: Text(item.universityName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Row(
            children: [
              Text(item.universityType == 'public' ? 'Public' : 'Private', style: TextStyle(fontSize: 12, color: color)),
              if (item.universityRanking != null) ...[
                const Text(' · ', style: TextStyle(color: AppColors.textTertiaryLight)),
                Text('Rank #${item.universityRanking}', style: const TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
              ],
            ],
          ),
          trailing: TextButton(
            onPressed: () => _quickAddApplication(context, ref),
            child: const Text('Track', style: TextStyle(fontSize: 12)),
          ),
        ),
      ),
    );
  }

  void _quickAddApplication(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(applicationsProvider.notifier).addApplication(universityId: item.universityId);
    if (context.mounted) {
      if (ok) {
        context.push('/track/applications');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to applications')));
      }
    }
  }
}