import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/review_provider.dart';

class UniversityReviewsSection extends ConsumerWidget {
  final String universityId;
  const UniversityReviewsSection({super.key, required this.universityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(universityReviewsProvider(universityId));
    final avgRating = ref.watch(universityRatingProvider(universityId));
    final hasReviewed = ref.watch(hasReviewedProvider(universityId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Student Reviews', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (!hasReviewed)
              TextButton.icon(
                onPressed: () => _showAddReviewSheet(context, ref),
                icon: const Icon(Icons.rate_review_rounded, size: 18),
                label: const Text('Write Review'),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Average rating summary
        reviewsState.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))),
          error: (msg) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(12)),
            child: Text(msg, style: TextStyle(color: AppColors.error, fontSize: 13)),
          ),
          success: (reviews) {
            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.reviews_outlined, size: 36, color: AppColors.textTertiaryLight),
                    const SizedBox(height: 8),
                    Text('No reviews yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiaryLight)),
                    const SizedBox(height: 4),
                    Text('Be the first to review!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Rating summary bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          _StarRow(rating: avgRating, size: 16),
                          const SizedBox(height: 2),
                          Text('${reviews.length} review${reviews.length > 1 ? 's' : ''}', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: _RatingBars(reviews: reviews)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Review list
                ...reviews.take(5).map((r) => _ReviewCard(review: r, universityId: universityId)),

                if (reviews.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('${reviews.length - 5} more reviews', style: TextStyle(fontSize: 13, color: AppColors.textTertiaryLight)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddReviewSheet(BuildContext context, WidgetRef ref) {
    int rating = 0;
    final titleC = TextEditingController();
    final bodyC = TextEditingController();
    final prosC = TextEditingController();
    final consC = TextEditingController();
    bool isStudent = false;

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
                    Text('Write a Review', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // Star rating
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () => setState(() => rating = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: i < rating ? AppColors.accent : AppColors.textTertiaryLight,
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (rating > 0) Center(child: Text(_ratingLabel(rating), style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 16),

                    TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title (optional)', hintText: 'e.g. Great campus life')),
                    const SizedBox(height: 12),
                    TextField(controller: bodyC, maxLines: 3, decoration: const InputDecoration(labelText: 'Your experience', hintText: 'Share your experience...')),
                    const SizedBox(height: 12),
                    TextField(controller: prosC, decoration: const InputDecoration(labelText: 'Pros (optional)', hintText: 'Best things about this university')),
                    const SizedBox(height: 12),
                    TextField(controller: consC, decoration: const InputDecoration(labelText: 'Cons (optional)', hintText: 'Things that could be better')),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Checkbox(value: isStudent, onChanged: (v) => setState(() => isStudent = v ?? false)),
                        const Text('I am a current student', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: rating == 0
                            ? null
                            : () async {
                                final ok = await ref.read(universityReviewsProvider(universityId).notifier).addReview(
                                      rating: rating,
                                      title: titleC.text.trim().isEmpty ? null : titleC.text.trim(),
                                      body: bodyC.text.trim().isEmpty ? null : bodyC.text.trim(),
                                      pros: prosC.text.trim().isEmpty ? null : prosC.text.trim(),
                                      cons: consC.text.trim().isEmpty ? null : consC.text.trim(),
                                      isCurrentStudent: isStudent,
                                    );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(ok ? 'Review submitted!' : 'Failed to submit review')),
                                  );
                                }
                              },
                        child: const Text('Submit Review'),
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

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) return Icon(Icons.star_rounded, size: size, color: AppColors.accent);
        if (i < rating) return Icon(Icons.star_half_rounded, size: size, color: AppColors.accent);
        return Icon(Icons.star_outline_rounded, size: size, color: AppColors.textTertiaryLight);
      }),
    );
  }
}

class _RatingBars extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _RatingBars({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final counts = List.filled(5, 0);
    for (final r in reviews) {
      counts[r.rating - 1]++;
    }
    final max = counts.reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = counts[star - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Text('$star', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.star_rounded, size: 10, color: AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: max > 0 ? count / max : 0,
                    minHeight: 6,
                    backgroundColor: AppColors.dividerLight,
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(width: 16, child: Text('$count', style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryLight))),
            ],
          ),
        );
      }),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final ReviewModel review;
  final String universityId;
  const _ReviewCard({required this.review, required this.universityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = ref.watch(currentUserProvider)?.id == review.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StarRow(rating: review.rating.toDouble(), size: 14),
              const SizedBox(width: 8),
              if (review.isCurrentStudent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Student', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                ),
              const Spacer(),
              Text(
                _timeAgo(review.createdAt),
                style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight),
              ),
              if (isOwn) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final ok = await ref.read(universityReviewsProvider(universityId).notifier).deleteReview(review.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Review deleted' : 'Failed to delete')));
                    }
                  },
                  child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                ),
              ],
            ],
          ),
          if (review.title != null) ...[
            const SizedBox(height: 6),
            Text(review.title!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
          if (review.body != null) ...[
            const SizedBox(height: 4),
            Text(review.body!, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4, color: AppColors.textSecondaryLight)),
          ],
          if (review.pros != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.thumb_up_rounded, size: 12, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(child: Text(review.pros!, style: TextStyle(fontSize: 12, color: AppColors.success))),
              ],
            ),
          ],
          if (review.cons != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.thumb_down_rounded, size: 12, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(child: Text(review.cons!, style: TextStyle(fontSize: 12, color: AppColors.error))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}