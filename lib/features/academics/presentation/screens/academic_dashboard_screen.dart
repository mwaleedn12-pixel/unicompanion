import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/semester_provider.dart';
import '../providers/assignment_provider.dart';
import '../../data/models/semester_model.dart';

class SemesterGpaPoint {
  final String label;
  final double semesterGpa;
  final double cumulativeCgpa;

  SemesterGpaPoint({
    required this.label,
    required this.semesterGpa,
    required this.cumulativeCgpa,
  });
}

class AcademicDashboardScreen extends ConsumerWidget {
  const AcademicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersState = ref.watch(semestersProvider);
    final semesters = List<SemesterModel>.from(semestersState.dataOrNull ?? const []);
    final upcomingAssignments = ref.watch(upcomingAssignmentsProvider);

    // Completed semesters, ordered by semester number, feed the trend charts.
    final completed = semesters.where((s) => s.isCompleted).toList()
      ..sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));

    final points = <SemesterGpaPoint>[];
    double totalQualityPoints = 0;
    double totalCredits = 0;

    for (final s in completed) {
      final gpa = s.gpa ?? s.computedGpa;
      final credits = s.totalCreditHours > 0 ? s.totalCreditHours : s.computedCreditHours;

      totalQualityPoints += gpa * credits;
      totalCredits += credits;
      final cgpaSoFar = totalCredits == 0 ? 0.0 : totalQualityPoints / totalCredits;

      points.add(SemesterGpaPoint(
        label: s.name,
        semesterGpa: gpa,
        cumulativeCgpa: double.parse(cgpaSoFar.toStringAsFixed(2)),
      ));
    }

    final currentCgpa = points.isEmpty ? 0.0 : points.last.cumulativeCgpa;

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Dashboard')),
      body: points.isEmpty
          ? _EmptyDashboardState(onAddSemester: () => context.push('/track/semesters'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CgpaSummaryCard(cgpa: currentCgpa, totalCredits: totalCredits.toInt()),
                  const SizedBox(height: 24),
                  Text('CGPA Progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  SizedBox(height: 220, child: _CgpaLineChart(points: points)),
                  const SizedBox(height: 24),
                  Text('Semester-wise GPA', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  SizedBox(height: 200, child: _SemesterGpaBarChart(points: points)),
                  const SizedBox(height: 24),
                  Text('Upcoming Deadlines', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _UpcomingDeadlinesList(assignments: upcomingAssignments.take(5).toList()),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  final VoidCallback onAddSemester;
  const _EmptyDashboardState({required this.onAddSemester});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
              child: Icon(Icons.insights_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'No completed semesters yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Mark a semester as completed in the Semester Manager to see your progress here.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAddSemester, child: const Text('Go to Semester Manager')),
          ],
        ),
      ),
    );
  }
}

class _CgpaSummaryCard extends StatelessWidget {
  final double cgpa;
  final int totalCredits;
  const _CgpaSummaryCard({required this.cgpa, required this.totalCredits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current CGPA', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              const SizedBox(height: 4),
              Text(cgpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Credits Earned', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              const SizedBox(height: 4),
              Text('$totalCredits', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CgpaLineChart extends StatelessWidget {
  final List<SemesterGpaPoint> points;
  const _CgpaLineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 4.0,
        gridData: const FlGridData(show: true, horizontalInterval: 1),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 1)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt() - 1;
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(points[i].label, style: const TextStyle(fontSize: 10)));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.15)),
            spots: [for (var i = 0; i < points.length; i++) FlSpot((i + 1).toDouble(), points[i].cumulativeCgpa)],
          ),
        ],
      ),
    );
  }
}

class _SemesterGpaBarChart extends StatelessWidget {
  final List<SemesterGpaPoint> points;
  const _SemesterGpaBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 4.0,
        gridData: const FlGridData(show: true, horizontalInterval: 1),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 1)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(points[i].label, style: const TextStyle(fontSize: 10)));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: points[i].semesterGpa, width: 18, borderRadius: BorderRadius.circular(4), color: AppColors.secondary),
            ]),
        ],
      ),
    );
  }
}

class _UpcomingDeadlinesList extends StatelessWidget {
  final List assignments; // List<AssignmentModel>
  const _UpcomingDeadlinesList({required this.assignments});

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: const Text("You're all caught up 🎉", textAlign: TextAlign.center),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          for (final a in assignments)
            ListTile(
              dense: true,
              leading: Icon(
                a.type == 'exam' ? Icons.description_rounded : (a.type == 'quiz' ? Icons.quiz_rounded : Icons.assignment_rounded),
                color: a.isOverdue ? AppColors.error : AppColors.accent,
                size: 20,
              ),
              title: Text(a.title, style: Theme.of(context).textTheme.bodyMedium),
              trailing: Text(
                DateFormat('MMM d').format(a.dueDate),
                style: TextStyle(fontWeight: FontWeight.w600, color: a.isOverdue ? AppColors.error : AppColors.textSecondaryLight, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}