import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/discussions_provider.dart';

class DiscussionsScreen extends ConsumerWidget {
  const DiscussionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discussionsProvider);
    final filtered = ref.watch(filteredDiscussionsProvider);
    final catFilter = ref.watch(discussionCategoryFilter);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Community', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text('Ask questions, share experiences', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
            ),
            const SizedBox(height: 14),

            // Category filter
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CatChip(label: 'All', isSelected: catFilter == null, onTap: () => ref.read(discussionCategoryFilter.notifier).state = null),
                  ...discussionCategories.entries.map((e) => _CatChip(
                    label: e.value,
                    isSelected: catFilter == e.key,
                    onTap: () => ref.read(discussionCategoryFilter.notifier).state = e.key,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: state.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading...'),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.read(discussionsProvider.notifier).load()),
                success: (_) {
                  if (filtered.isEmpty) {
                    return AppEmptyView(
                      icon: Icons.forum_outlined,
                      title: 'No discussions yet',
                      subtitle: catFilter != null ? 'No posts in this category' : 'Be the first to start a discussion!',
                      action: PrimaryButton(text: 'Start Discussion', icon: Icons.add_rounded, onPressed: () => _showCreateSheet(context, ref)),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(discussionsProvider.notifier).load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _DiscussionCard(discussion: filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    final titleC = TextEditingController();
    final bodyC = TextEditingController();
    String category = 'general';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Discussion', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title', hintText: 'What\'s your question?')),
                    const SizedBox(height: 12),
                    TextField(controller: bodyC, maxLines: 4, decoration: const InputDecoration(labelText: 'Details', hintText: 'Explain your question or topic...')),
                    const SizedBox(height: 12),
                    Text('Category', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: discussionCategories.entries.map((e) {
                        final isSelected = category == e.key;
                        return ChoiceChip(
                          label: Text(e.value),
                          selected: isSelected,
                          onSelected: (_) => setState(() => category = e.key),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? AppColors.primary : null),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: titleC.text.trim().isEmpty || bodyC.text.trim().isEmpty ? null : () async {
                          final ok = await ref.read(discussionsProvider.notifier).create(title: titleC.text.trim(), body: bodyC.text.trim(), category: category);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Posted!' : 'Failed to post')));
                          }
                        },
                        child: const Text('Post Discussion'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DiscussionCard extends ConsumerWidget {
  final DiscussionModel discussion;
  const _DiscussionCard({required this.discussion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = ref.watch(currentUserProvider)?.id == discussion.userId;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _DiscussionDetailScreen(discussion: discussion))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
                  child: Text(discussion.categoryLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
                const Spacer(),
                Text(_timeAgo(discussion.createdAt), style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight)),
                if (isOwn) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      final ok = await ref.read(discussionsProvider.notifier).delete(discussion.id);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Deleted' : 'Failed')));
                    },
                    child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(discussion.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(discussion.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textTertiaryLight),
                const SizedBox(width: 4),
                Text('${discussion.replyCount} ${discussion.replyCount == 1 ? 'reply' : 'replies'}', style: TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

// ── Detail Screen (inline) ──

class _DiscussionDetailScreen extends ConsumerStatefulWidget {
  final DiscussionModel discussion;
  const _DiscussionDetailScreen({required this.discussion});

  @override
  ConsumerState<_DiscussionDetailScreen> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_DiscussionDetailScreen> {
  final _replyC = TextEditingController();

  @override
  void dispose() {
    _replyC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.discussion;
    final repliesState = ref.watch(discussionRepliesProvider(d.id));
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Discussion', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                      child: Text(d.categoryLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                    const SizedBox(height: 10),
                    Text(d.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(d.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 20),

                    // Replies
                    Text('Replies (${d.replyCount})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    repliesState.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))),
                      error: (msg) => Text(msg, style: TextStyle(color: AppColors.error)),
                      success: (replies) {
                        if (replies.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
                            child: Text('No replies yet. Be the first!', style: TextStyle(color: AppColors.textTertiaryLight), textAlign: TextAlign.center),
                          );
                        }
                        return Column(
                          children: replies.map((r) {
                            final isOwn = r.userId == currentUserId;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24, height: 24,
                                        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(isOwn ? 'You' : 'Student', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Text(_timeAgo(r.createdAt), style: TextStyle(fontSize: 10, color: AppColors.textTertiaryLight)),
                                      if (isOwn) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => ref.read(discussionRepliesProvider(d.id).notifier).deleteReply(r.id),
                                          child: Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.error),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(r.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Reply input
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 8, 8 + MediaQuery.of(context).viewPadding.bottom),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyC,
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.06),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () async {
                      if (_replyC.text.trim().isEmpty) return;
                      final ok = await ref.read(discussionRepliesProvider(d.id).notifier).addReply(_replyC.text.trim());
                      if (ok) {
                        _replyC.clear();
                        // Refresh the discussions list to update reply count
                        ref.read(discussionsProvider.notifier).load();
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Reply posted!' : 'Failed to post')));
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CatChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimaryLight)),
        ),
      ),
    );
  }
}