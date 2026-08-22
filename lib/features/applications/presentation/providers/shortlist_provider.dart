import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/datasources/applications_remote_datasource.dart';
import '../../data/models/shortlist_model.dart';
import '../../data/repositories/applications_repository_impl.dart';
import '../../domain/repositories/applications_repository.dart';

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ApplicationsRepositoryImpl(ApplicationsRemoteDatasource(client));
});

final shortlistProvider = StateNotifierProvider<ShortlistNotifier, UiState<List<ShortlistModel>>>((ref) {
  final repository = ref.watch(applicationsRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  final notifier = ShortlistNotifier(repository, userId);
  if (userId != null) notifier.load();
  return notifier;
});

/// Quick lookup used by the university detail screen's bookmark button.
final isShortlistedProvider = Provider.family<bool, String>((ref, universityId) {
  final state = ref.watch(shortlistProvider);
  return state.dataOrNull?.any((s) => s.universityId == universityId) ?? false;
});

class ShortlistNotifier extends StateNotifier<UiState<List<ShortlistModel>>> {
  final ApplicationsRepository _repository;
  final String? _userId;

  ShortlistNotifier(this._repository, this._userId) : super(const UiState.initial());

  Future<void> load() async {
    if (_userId == null) return;
    state = const UiState.loading();
    final result = await _repository.getShortlist(_userId);
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<bool> toggle(String universityId) async {
    if (_userId == null) return false;
    final isCurrentlyShortlisted = state.dataOrNull?.any((s) => s.universityId == universityId) ?? false;
    final result = isCurrentlyShortlisted
        ? await _repository.removeFromShortlistByUniversity(_userId, universityId)
        : await _repository.addToShortlist(_userId, universityId);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> remove(String id) async {
    final result = await _repository.removeFromShortlist(id);
    if (result.isSuccess) {
      await load();
      return true;
    }
    return false;
  }
}