import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/models/assignment_model.dart';
import '../../domain/repositories/academics_repository.dart';
import 'semester_provider.dart';

final assignmentsProvider = StateNotifierProvider<AssignmentsNotifier, UiState<List<AssignmentModel>>>((ref) {
  final repository = ref.watch(academicsRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  final notifier = AssignmentsNotifier(repository, userId);
  if (userId != null) notifier.load();
  return notifier;
});

/// Upcoming (incomplete, not overdue-only) assignments sorted by due date — used by the Track screen.
final upcomingAssignmentsProvider = Provider<List<AssignmentModel>>((ref) {
  final state = ref.watch(assignmentsProvider);
  final all = state.dataOrNull ?? [];
  final upcoming = all.where((a) => !a.isCompleted).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return upcoming;
});

class AssignmentsNotifier extends StateNotifier<UiState<List<AssignmentModel>>> {
  final AcademicsRepository _repository;
  final String? _userId;

  AssignmentsNotifier(this._repository, this._userId) : super(const UiState.initial());

  Future<void> load() async {
    if (_userId == null) return;
    state = const UiState.loading();
    final result = await _repository.getAssignments(_userId);
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<bool> addAssignment({
    required String title,
    required String type,
    required DateTime dueDate,
    String priority = 'medium',
    String? courseId,
    String? semesterId,
    double? weight,
    String? notes,
  }) async {
    if (_userId == null) return false;
    final assignment = AssignmentModel(
      id: '',
      userId: _userId,
      courseId: courseId,
      semesterId: semesterId,
      title: title,
      type: type,
      dueDate: dueDate,
      priority: priority,
      weight: weight,
      notes: notes,
    );
    final result = await _repository.createAssignment(assignment);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> toggleComplete(AssignmentModel assignment) async {
    final result = await _repository.toggleAssignmentComplete(assignment.id, !assignment.isCompleted);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> deleteAssignment(String id) async {
    final result = await _repository.deleteAssignment(id);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }
}