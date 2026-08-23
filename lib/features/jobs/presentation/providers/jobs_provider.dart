import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';

// ── Model ──

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String jobType;
  final String field;
  final String? description;
  final String? requirements;
  final String? applyUrl;
  final String? salaryRange;
  final DateTime? deadline;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.field,
    this.description,
    this.requirements,
    this.applyUrl,
    this.salaryRange,
    this.deadline,
    required this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      jobType: json['job_type'],
      field: json['field'],
      description: json['description'],
      requirements: json['requirements'],
      applyUrl: json['apply_url'],
      salaryRange: json['salary_range'],
      deadline: json['deadline'] == null ? null : DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get typeLabel {
    switch (jobType) {
      case 'internship': return 'Internship';
      case 'full_time': return 'Full-Time';
      case 'part_time': return 'Part-Time';
      case 'remote': return 'Remote';
      case 'contract': return 'Contract';
      default: return jobType;
    }
  }

  bool get isDeadlinePassed => deadline != null && deadline!.isBefore(DateTime.now());
  int? get daysLeft => deadline == null ? null : deadline!.difference(DateTime.now()).inDays;
}

// ── Filter ──

class JobFilter {
  final String? type;
  final String? field;
  final String search;
  const JobFilter({this.type, this.field, this.search = ''});
  JobFilter copyWith({String? type, String? field, String? search}) =>
      JobFilter(type: type ?? this.type, field: field ?? this.field, search: search ?? this.search);
}

// ── Providers ──

final jobFilterProvider = StateProvider<JobFilter>((ref) => const JobFilter());

final jobsProvider = StateNotifierProvider<JobsNotifier, UiState<List<JobModel>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final notifier = JobsNotifier(client);
  notifier.load();
  return notifier;
});

final filteredJobsProvider = Provider<List<JobModel>>((ref) {
  final all = ref.watch(jobsProvider).dataOrNull ?? [];
  final filter = ref.watch(jobFilterProvider);

  return all.where((j) {
    if (filter.type != null && j.jobType != filter.type) return false;
    if (filter.field != null && j.field != filter.field) return false;
    if (filter.search.isNotEmpty) {
      final q = filter.search.toLowerCase();
      if (!j.title.toLowerCase().contains(q) && !j.company.toLowerCase().contains(q) && !j.location.toLowerCase().contains(q)) return false;
    }
    return true;
  }).toList();
});

final jobFieldsProvider = Provider<List<String>>((ref) {
  final all = ref.watch(jobsProvider).dataOrNull ?? [];
  return all.map((j) => j.field).toSet().toList()..sort();
});

class JobsNotifier extends StateNotifier<UiState<List<JobModel>>> {
  final dynamic _client;
  JobsNotifier(this._client) : super(const UiState.initial());

  Future<void> load() async {
    state = const UiState.loading();
    try {
      final data = await _client.from('jobs').select().eq('is_active', true).order('created_at', ascending: false);
      state = UiState.success((data as List).map<JobModel>((e) => JobModel.fromJson(e)).toList());
    } catch (e) {
      state = UiState.error('Failed to load jobs: $e');
    }
  }
}