import '../../../../core/utils/result.dart';
import '../../data/models/university_model.dart';

abstract class ExploreRepository {
  Future<Result<List<UniversityModel>>> getUniversities({
    String? search,
    String? type,
    String? sortBy,
  });
  Future<Result<UniversityModel>> getUniversityById(String id);
}