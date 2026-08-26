import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../providers/review_provider.dart';

class UniversityReviewsScreen extends ConsumerStatefulWidget {
  final String universityId;
  final String universityName;

  const UniversityReviewsScreen({
    super.key,
    required this.universityId,
    required this.universityName,
  });

  @override
  ConsumerState<UniversityReviewsScreen> createState() => _UniversityReviewsScreenState();
}

class _UniversityReviewsScreenState extends ConsumerState<UniversityReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(universityReviewsProvider(widget.universityId));
    final avgRating = ref.watch(universityRatingProvider(widget.universityId));
    final hasReviewed = ref.watch(hasReviewedProvider(widget.universityId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reviews', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(widget.universityName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms),

            const SizedBox(height: 16),

            // ── Rating summary ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFF1C2B4A), const Color(0xFF10192E)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          avgRating > 0 ? avgRating.toStringAsFixed(1) : '--',
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFC9A24B),
                            size: 18,
                          )),
                        ),
                        const SizedBox(height: 4),
                        reviewsState.when(
                          initial: () => const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_) => const SizedBox.shrink(),
                          success: (reviews) => Text(
                            '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: reviewsState.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_) => const SizedBox.shrink(),
                        success: (reviews) => _RatingBars(reviews: reviews),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.08, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 16),

            // ── Write Review button ──
            if (!hasReviewed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showWriteReviewSheet(context),
                    icon: const Icon(Icons.rate_review_rounded, size: 18),
                    label: const Text('Write a Review'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // ── Reviews list ──
            Expanded(
              child: reviewsState.when(
                initial: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const ListTileSkeleton(),
                ),
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const ListTileSkeleton(),
                ),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.invalidate(universityReviewsProvider(widget.universityId))),
                success: (reviews) {
                  if (reviews.isEmpty) {
                    return const AppEmptyView(
                      icon: Icons.reviews_outlined,
                      title: 'No Reviews Yet',
                      subtitle: 'Be the first to review this university!',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(universityReviewsProvider(widget.universityId));
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: reviews.length,
                      itemBuilder: (context, i) => _ReviewCard(review: reviews[i])
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (i.clamp(0, 6) * 60).ms)
                          .slideY(begin: 0.04, end: 0, duration: 300.ms, delay: (i.clamp(0, 6) * 60).ms),
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

  void _showWriteReviewSheet(BuildContext context) {
    int selectedRating = 0;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final prosCtrl = TextEditingController();
    final consCtrl = TextEditingController();
    bool isStudent = false;
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text('Write a Review', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // Star rating
                  Text('Rating', style: Theme.of(ctx).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) => GestureDetector(
                      onTap: () {
                        AppHaptics.selection();
                        setSheetState(() => selectedRating = i + 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFC9A24B),
                          size: 36,
                        ),
                      ),
                    )),
                  ),

                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: bodyCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Your experience', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: prosCtrl, decoration: InputDecoration(labelText: '👍 Pros (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: consCtrl, decoration: InputDecoration(labelText: '👎 Cons (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Checkbox(value: isStudent, onChanged: (v) => setSheetState(() => isStudent = v ?? false)),
                      const Text('I am a current student'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  PrimaryButton(
                    text: 'Submit Review',
                    isLoading: submitting,
                    onPressed: selectedRating == 0
                        ? null
                        : () async {
                            setSheetState(() => submitting = true);
                            final success = await ref.read(universityReviewsProvider(widget.universityId).notifier).addReview(
                              rating: selectedRating,
                              title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
                              body: bodyCtrl.text.trim().isEmpty ? null : bodyCtrl.text.trim(),
                              pros: prosCtrl.text.trim().isEmpty ? null : prosCtrl.text.trim(),
                              cons: consCtrl.text.trim().isEmpty ? null : consCtrl.text.trim(),
                              isCurrentStudent: isStudent,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              context.showSnackBar(success ? 'Review submitted! 🎉' : 'Failed to submit review');
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _RatingBars extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _RatingBars({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      counts[r.rating] = (counts[r.rating] ?? 0) + 1;
    }
    final max = counts.values.reduce((a, b) => a > b ? a : b).clamp(1, 9999);

    return Column(
      children: [5, 4, 3, 2, 1].map((star) {
        final count = counts[star]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text('$star', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: count / max,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFC9A24B)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(width: 16, child: Text('$count', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _timeAgo(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  (review.userName ?? 'S')[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review.userName ?? 'Student', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (review.isCurrentStudent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Current Student', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success)),
                          ),
                        ],
                      ],
                    ),
                    Text(timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFC9A24B),
                  size: 14,
                )),
              ),
            ],
          ),

          if (review.title != null) ...[
            const SizedBox(height: 10),
            Text(review.title!, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],

          if (review.body != null) ...[
            const SizedBox(height: 6),
            Text(review.body!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
          ],

          if (review.pros != null || review.cons != null) ...[
            const SizedBox(height: 10),
            if (review.pros != null)
              _ProConRow(icon: Icons.thumb_up_rounded, text: review.pros!, color: AppColors.success),
            if (review.cons != null) ...[
              const SizedBox(height: 4),
              _ProConRow(icon: Icons.thumb_down_rounded, text: review.cons!, color: AppColors.error),
            ],
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? 's' : ''} ago';
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return 'Just now';
  }
}

class _ProConRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _ProConRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight))),
      ],
    );
  }
}