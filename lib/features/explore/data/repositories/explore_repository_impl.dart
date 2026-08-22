import '../../../../core/utils/result.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';
import '../models/university_model.dart';
import '../models/program_model.dart';
import '../models/campus_model.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDatasource _datasource;

  ExploreRepositoryImpl(this._datasource);

  @override
  Future<Result<List<UniversityModel>>> getUniversities({
    String? search,
    String? type,
    String? sortBy,
  }) async {
    try {
      final data = await _datasource.getUniversities(
        search: search,
        type: type,
        sortBy: sortBy,
      );
      final universities = data.map((e) => UniversityModel.fromJson(e)).toList();
      return Result.success(universities);
    } catch (e) {
      return Result.failure('Failed to load universities: $e');
    }
  }

  @override
  Future<Result<UniversityModel>> getUniversityById(String id) async {
    try {
      final data = await _datasource.getUniversityById(id);
      return Result.success(UniversityModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to load university: $e');
    }
  }

  // ── Programs ──

  @override
  Future<Result<List<ProgramModel>>> getPrograms({
    String? search,
    String? field,
    String? degreeLevel,
    String? universityId,
  }) async {
    try {
      final data = await _datasource.getPrograms(
        search: search,
        field: field,
        degreeLevel: degreeLevel,
        universityId: universityId,
      );
      final programs = data.map((e) => ProgramModel.fromJson(e)).toList();
      return Result.success(programs);
    } catch (e) {
      return Result.failure('Failed to load programs: $e');
    }
  }

  @override
  Future<Result<List<ProgramModel>>> getProgramsByUniversity(String universityId) async {
    try {
      final data = await _datasource.getProgramsByUniversity(universityId);
      final programs = data.map((e) => ProgramModel.fromJson(e)).toList();
      return Result.success(programs);
    } catch (e) {
      return Result.failure('Failed to load programs: $e');
    }
  }

  // ── Campuses ──

  @override
  Future<Result<List<CampusModel>>> getCampuses({
    String? universityId,
    String? city,
  }) async {
    try {
      final data = await _datasource.getCampuses(
        universityId: universityId,
        city: city,
      );
      final campuses = data.map((e) => CampusModel.fromJson(e)).toList();
      return Result.success(campuses);
    } catch (e) {
      return Result.failure('Failed to load campuses: $e');
    }
  }

  @override
  Future<Result<List<CampusModel>>> getCampusesByUniversity(String universityId) async {
    try {
      final data = await _datasource.getCampusesByUniversity(universityId);
      final campuses = data.map((e) => CampusModel.fromJson(e)).toList();
      return Result.success(campuses);
    } catch (e) {
      return Result.failure('Failed to load campuses: $e');
    }
  }

  @override
  Future<Result<List<String>>> getCampusCities() async {
    try {
      final cities = await _datasource.getCampusCities();
      return Result.success(cities);
    } catch (e) {
      return Result.failure('Failed to load cities: $e');
    }
  }
}