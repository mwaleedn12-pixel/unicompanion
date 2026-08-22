import '../../../../core/utils/result.dart';
import '../../data/models/shortlist_model.dart';
import '../../data/models/application_model.dart';

abstract class ApplicationsRepository {
  // Shortlist
  Future<Result<List<ShortlistModel>>> getShortlist(String userId);
  Future<Result<bool>> isShortlisted(String userId, String universityId);
  Future<Result<void>> addToShortlist(String userId, String universityId, {String? notes});
  Future<Result<void>> removeFromShortlist(String id);
  Future<Result<void>> removeFromShortlistByUniversity(String userId, String universityId);

  // Applications
  Future<Result<List<ApplicationModel>>> getApplications(String userId);
  Future<Result<ApplicationModel>> createApplication(ApplicationModel application);
  Future<Result<ApplicationModel>> updateApplication(ApplicationModel application);
  Future<Result<void>> deleteApplication(String id);
}