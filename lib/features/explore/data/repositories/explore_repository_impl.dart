import '../../../../core/utils/result.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';
import '../models/university_model.dart';

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
}