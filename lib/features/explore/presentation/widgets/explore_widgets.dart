import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/models/university_model.dart';
import '../../../applications/presentation/providers/shortlist_provider.dart';

class UniversityCard extends ConsumerWidget {
  final UniversityModel university;
  final VoidCallback onTap;

  const UniversityCard({super.key, required this.university, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShortlisted = ref.watch(isShortlistedProvider(university.id));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // University Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _avatarColors(university.type),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _avatarColors(university.type)[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    university.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _TypeBadge(type: university.typeLabel),
                        if (university.rankingNational != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events_rounded, size: 12, color: AppColors.accentDark),
                                const SizedBox(width: 3),
                                Text(
                                  '#${university.rankingNational}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Bookmark toggle ──
              _ShortlistButton(universityId: university.id, isShortlisted: isShortlisted),

              const SizedBox(width: 6),

              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _avatarColors(String type) {
    switch (type) {
      case 'public':
        return [AppColors.primary, AppColors.primaryLight];
      case 'private':
        return [AppColors.secondary, AppColors.secondaryLight];
      default:
        return [AppColors.accent, AppColors.accentLight];
    }
  }
}

/// Animated bookmark toggle with loading + error feedback
class _ShortlistButton extends ConsumerStatefulWidget {
  final String universityId;
  final bool isShortlisted;
  const _ShortlistButton({required this.universityId, required this.isShortlisted});

  @override
  ConsumerState<_ShortlistButton> createState() => _ShortlistButtonState();
}

class _ShortlistButtonState extends ConsumerState<_ShortlistButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _busy ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: widget.isShortlisted
              ? AppColors.primary.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _busy
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                widget.isShortlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                size: 20,
                color: widget.isShortlisted ? AppColors.primary : AppColors.textTertiaryLight,
              ),
      ),
    );
  }

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      final ok = await ref.read(shortlistProvider.notifier).toggle(widget.universityId);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isShortlisted ? 'Removed from shortlist' : 'Added to shortlist'),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed — check your connection'), duration: Duration(seconds: 2)),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong'), duration: Duration(seconds: 2)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isPublic = type == 'Public';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublic ? AppColors.primarySurface : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPublic ? AppColors.primaryDark : AppColors.secondaryDark,
        ),
      ),
    );
  }
}

/// Filter chip for explore screen
class FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipButton({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}