import '../../../../core/utils/result.dart';
import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_datasource.dart';
import '../models/shortlist_model.dart';
import '../models/application_model.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  final ApplicationsRemoteDatasource _datasource;

  ApplicationsRepositoryImpl(this._datasource);

  @override
  Future<Result<List<ShortlistModel>>> getShortlist(String userId) async {
    try {
      final data = await _datasource.getShortlist(userId);
      return Result.success(data.map((e) => ShortlistModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure('Failed to load shortlist: $e');
    }
  }

  @override
  Future<Result<bool>> isShortlisted(String userId, String universityId) async {
    try {
      final result = await _datasource.isShortlisted(userId, universityId);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to check shortlist: $e');
    }
  }

  @override
  Future<Result<void>> addToShortlist(String userId, String universityId, {String? notes}) async {
    try {
      await _datasource.addToShortlist(userId, universityId, notes: notes);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to add to shortlist: $e');
    }
  }

  @override
  Future<Result<void>> removeFromShortlist(String id) async {
    try {
      await _datasource.removeFromShortlist(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to remove from shortlist: $e');
    }
  }

  @override
  Future<Result<void>> removeFromShortlistByUniversity(String userId, String universityId) async {
    try {
      await _datasource.removeFromShortlistByUniversity(userId, universityId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to remove from shortlist: $e');
    }
  }

  @override
  Future<Result<List<ApplicationModel>>> getApplications(String userId) async {
    try {
      final data = await _datasource.getApplications(userId);
      return Result.success(data.map((e) => ApplicationModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure('Failed to load applications: $e');
    }
  }

  @override
  Future<Result<ApplicationModel>> createApplication(ApplicationModel application) async {
    try {
      final data = await _datasource.createApplication(application.toInsertJson());
      return Result.success(ApplicationModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to add application: $e');
    }
  }

  @override
  Future<Result<ApplicationModel>> updateApplication(ApplicationModel application) async {
    try {
      final data = await _datasource.updateApplication(application.id, application.toInsertJson());
      return Result.success(ApplicationModel.fromJson(data));
    } catch (e) {
      return Result.failure('Failed to update application: $e');
    }
  }

  @override
  Future<Result<void>> deleteApplication(String id) async {
    try {
      await _datasource.deleteApplication(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete application: $e');
    }
  }
}