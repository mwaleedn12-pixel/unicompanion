import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/datasources/academics_remote_datasource.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/academics_repository_impl.dart';
import '../../domain/repositories/academics_repository.dart';

final academicsRepositoryProvider = Provider<AcademicsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AcademicsRepositoryImpl(AcademicsRemoteDatasource(client));
});

final semestersProvider = StateNotifierProvider<SemestersNotifier, UiState<List<SemesterModel>>>((ref) {
  final repository = ref.watch(academicsRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  final notifier = SemestersNotifier(repository, userId);
  if (userId != null) notifier.load();
  return notifier;
});

/// Total credits completed across all semesters marked completed — feeds the
/// Track screen's Degree Progress bar.
final totalCompletedCreditsProvider = Provider<double>((ref) {
  final state = ref.watch(semestersProvider);
  final semesters = state.dataOrNull ?? const [];
  return semesters
      .where((s) => s.isCompleted)
      .fold<double>(0.0, (sum, s) => sum + s.computedCreditHours);
});

class SemestersNotifier extends StateNotifier<UiState<List<SemesterModel>>> {
  final AcademicsRepository _repository;
  final String? _userId;

  SemestersNotifier(this._repository, this._userId) : super(const UiState.initial());

  Future<void> load() async {
    if (_userId == null) return;
    state = const UiState.loading();
    final result = await _repository.getSemesters(_userId);
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<bool> addSemester(String name, int semesterNumber) async {
    if (_userId == null) return false;
    final semester = SemesterModel(id: '', userId: _userId, name: name, semesterNumber: semesterNumber);
    final result = await _repository.createSemester(semester);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> deleteSemester(String id) async {
    final result = await _repository.deleteSemester(id);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> toggleSemesterCompleted(SemesterModel semester) async {
    final updated = semester.copyWith(
      isCompleted: !semester.isCompleted,
      gpa: semester.computedGpa,
      totalCreditHours: semester.computedCreditHours,
    );
    final result = await _repository.updateSemester(updated);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> addCourse({
    required String semesterId,
    required String name,
    String? code,
    int creditHours = 3,
  }) async {
    if (_userId == null) return false;
    final course = CourseModel(
      id: '',
      userId: _userId,
      semesterId: semesterId,
      name: name,
      code: code,
      creditHours: creditHours,
    );
    final result = await _repository.createCourse(course);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> updateCourseGrade(CourseModel course, String grade, double gradePoints) async {
    final updated = course.copyWith(grade: grade, gradePoints: gradePoints);
    final result = await _repository.updateCourse(updated);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> deleteCourse(String id) async {
    final result = await _repository.deleteCourse(id);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }
}