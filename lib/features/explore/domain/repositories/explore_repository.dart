import '../../../../core/utils/result.dart';
import '../../data/models/university_model.dart';
import '../../data/models/program_model.dart';
import '../../data/models/campus_model.dart';

abstract class ExploreRepository {
  Future<Result<List<UniversityModel>>> getUniversities({
    String? search,
    String? type,
    String? sortBy,
  });
  Future<Result<UniversityModel>> getUniversityById(String id);

  // Programs
  Future<Result<List<ProgramModel>>> getPrograms({
    String? search,
    String? field,
    String? degreeLevel,
    String? universityId,
  });
  Future<Result<List<ProgramModel>>> getProgramsByUniversity(String universityId);

  // Campuses
  Future<Result<List<CampusModel>>> getCampuses({
    String? universityId,
    String? city,
    String? search,
  });
  Future<Result<List<CampusModel>>> getCampusesByUniversity(String universityId);
  Future<Result<List<String>>> getCampusCities();
}