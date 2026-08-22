import '../../../../core/utils/result.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/assignment_model.dart';

abstract class AcademicsRepository {
  // Semesters (each returned with its courses populated)
  Future<Result<List<SemesterModel>>> getSemesters(String userId);
  Future<Result<SemesterModel>> createSemester(SemesterModel semester);
  Future<Result<SemesterModel>> updateSemester(SemesterModel semester);
  Future<Result<void>> deleteSemester(String id);

  // Courses
  Future<Result<CourseModel>> createCourse(CourseModel course);
  Future<Result<CourseModel>> updateCourse(CourseModel course);
  Future<Result<void>> deleteCourse(String id);

  // Assignments
  Future<Result<List<AssignmentModel>>> getAssignments(String userId);
  Future<Result<AssignmentModel>> createAssignment(AssignmentModel assignment);
  Future<Result<AssignmentModel>> updateAssignment(AssignmentModel assignment);
  Future<Result<void>> deleteAssignment(String id);
  Future<Result<AssignmentModel>> toggleAssignmentComplete(String id, bool isCompleted);
}