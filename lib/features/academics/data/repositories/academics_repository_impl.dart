import '../../../../core/utils/result.dart';
import '../../domain/repositories/academics_repository.dart';
import '../datasources/academics_remote_datasource.dart';
import '../models/semester_model.dart';
import '../models/course_model.dart';
import '../models/assignment_model.dart';

class AcademicsRepositoryImpl implements AcademicsRepository {
  final AcademicsRemoteDatasource _datasource;

  AcademicsRepositoryImpl(this._datasource);

  @override
  Future<Result<List<SemesterModel>>> getSemesters(String userId) async {
    try {
      final semesterRows = await _datasource.getSemesters(userId);
      final courseRows = await _datasource.getCourses(userId);
      final courses = courseRows.map((e) => CourseModel.fromJson(e)).toList();

      final semesters = semesterRows.map((row) {
        final semesterCourses = courses.where((c) => c.semesterId == row['id']).toList();
        return SemesterModel.fromJson(row, courses: semesterCourses);
      }).toList();

      return Result.success(semesters);
    } catch (e) {
      return Result.failure('Failed to load semesters: $e');
    }
  }

  @override
  Future<Result<SemesterModel>> createSemester(SemesterModel semester) async {
    try {
      final data = await _datasource.createSemester(semester.toInsertJson());
      return Result.success(SemesterModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to create semester: $e');
    }
  }

  @override
  Future<Result<SemesterModel>> updateSemester(SemesterModel semester) async {
    try {
      final data = await _datasource.updateSemester(semester.id, semester.toInsertJson());
      return Result.success(SemesterModel.fromJson(data, courses: semester.courses));
    } catch (e) {
      return Result.failure('Failed to update semester: $e');
    }
  }

  @override
  Future<Result<void>> deleteSemester(String id) async {
    try {
      await _datasource.deleteSemester(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete semester: $e');
    }
  }

  @override
  Future<Result<CourseModel>> createCourse(CourseModel course) async {
    try {
      final data = await _datasource.createCourse(course.toInsertJson());
      return Result.success(CourseModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to add course: $e');
    }
  }

  @override
  Future<Result<CourseModel>> updateCourse(CourseModel course) async {
    try {
      final data = await _datasource.updateCourse(course.id, course.toInsertJson());
      return Result.success(CourseModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to update course: $e');
    }
  }

  @override
  Future<Result<void>> deleteCourse(String id) async {
    try {
      await _datasource.deleteCourse(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete course: $e');
    }
  }

  @override
  Future<Result<List<AssignmentModel>>> getAssignments(String userId) async {
    try {
      final data = await _datasource.getAssignments(userId);
      return Result.success(data.map((e) => AssignmentModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure('Failed to load assignments: $e');
    }
  }

  @override
  Future<Result<AssignmentModel>> createAssignment(AssignmentModel assignment) async {
    try {
      final data = await _datasource.createAssignment(assignment.toInsertJson());
      return Result.success(AssignmentModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to add assignment: $e');
    }
  }

  @override
  Future<Result<AssignmentModel>> updateAssignment(AssignmentModel assignment) async {
    try {
      final data = await _datasource.updateAssignment(assignment.id, assignment.toInsertJson());
      return Result.success(AssignmentModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to update assignment: $e');
    }
  }

  @override
  Future<Result<void>> deleteAssignment(String id) async {
    try {
      await _datasource.deleteAssignment(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete assignment: $e');
    }
  }

  @override
  Future<Result<AssignmentModel>> toggleAssignmentComplete(String id, bool isCompleted) async {
    try {
      final data = await _datasource.toggleAssignmentComplete(id, isCompleted);
      return Result.success(AssignmentModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to update assignment: $e');
    }
  }
}