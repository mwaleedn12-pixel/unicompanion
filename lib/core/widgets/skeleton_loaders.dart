import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Base shimmer wrapper — wraps any child in a shimmer effect
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Reusable shimmer wrapper
class ShimmerWrap extends StatelessWidget {
  final Widget child;
  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }
}

/// Skeleton for a university list card
class UniversityCardSkeleton extends StatelessWidget {
  const UniversityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48, borderRadius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 10),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a campus card
class CampusCardSkeleton extends StatelessWidget {
  const CampusCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 44, height: 44, borderRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: double.infinity, height: 14),
                      const SizedBox(height: 6),
                      ShimmerBox(width: 100, height: 10),
                    ],
                  ),
                ),
                ShimmerBox(width: 50, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(4, (_) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ShimmerBox(width: 70, height: 28, borderRadius: 14),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for stat cards (2 side by side)
class StatCardsSkeleton extends StatelessWidget {
  const StatCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Row(
        children: [
          Expanded(child: ShimmerBox(width: double.infinity, height: 110, borderRadius: 18)),
          const SizedBox(width: 12),
          Expanded(child: ShimmerBox(width: double.infinity, height: 110, borderRadius: 18)),
        ],
      ),
    );
  }
}

/// Skeleton for a tool/list item
class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 42, height: 42, borderRadius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 160, height: 14),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 100, height: 10),
                ],
              ),
            ),
            const ShimmerBox(width: 32, height: 32, borderRadius: 8),
          ],
        ),
      ),
    );
  }
}

/// Full-screen skeleton for university list
class UniversityListSkeleton extends StatelessWidget {
  final int count;
  const UniversityListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const UniversityCardSkeleton(),
    );
  }
}

/// Full-screen skeleton for campus list
class CampusListSkeleton extends StatelessWidget {
  final int count;
  const CampusListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const CampusCardSkeleton(),
    );
  }
}