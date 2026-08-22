import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/models/application_model.dart';
import '../../domain/repositories/applications_repository.dart';
import 'shortlist_provider.dart';

final applicationsProvider = StateNotifierProvider<ApplicationsNotifier, UiState<List<ApplicationModel>>>((ref) {
  final repository = ref.watch(applicationsRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  final notifier = ApplicationsNotifier(repository, userId);
  if (userId != null) notifier.load();
  return notifier;
});

/// Applications with a deadline within the next 30 days, feeds the Track screen.
final upcomingDeadlinesProvider = Provider<List<ApplicationModel>>((ref) {
  final all = ref.watch(applicationsProvider).dataOrNull ?? [];
  final upcoming = all.where((a) => a.deadline != null && !a.isDeadlinePassed && !a.isRejected).toList()
    ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  return upcoming;
});

class ApplicationsNotifier extends StateNotifier<UiState<List<ApplicationModel>>> {
  final ApplicationsRepository _repository;
  final String? _userId;

  ApplicationsNotifier(this._repository, this._userId) : super(const UiState.initial());

  Future<void> load() async {
    if (_userId == null) return;
    state = const UiState.loading();
    final result = await _repository.getApplications(_userId);
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<bool> addApplication({
    required String universityId,
    String? programName,
    String status = 'interested',
    DateTime? deadline,
    String? notes,
  }) async {
    if (_userId == null) return false;
    final application = ApplicationModel(
      id: '',
      userId: _userId,
      universityId: universityId,
      programName: programName,
      status: status,
      deadline: deadline,
      notes: notes,
      createdAt: DateTime.now(),
      universityName: '',
    );
    final result = await _repository.createApplication(application);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> updateStatus(ApplicationModel application, String status) async {
    final shouldStampAppliedDate = status == 'applied' && application.appliedDate == null;
    final updated = application.copyWith(
      status: status,
      appliedDate: shouldStampAppliedDate ? DateTime.now() : null,
    );
    final result = await _repository.updateApplication(updated);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> deleteApplication(String id) async {
    final result = await _repository.deleteApplication(id);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }
}