import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/datasources/explore_remote_datasource.dart';
import '../../data/models/university_model.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/repositories/explore_repository.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ExploreRepositoryImpl(ExploreRemoteDatasource(client));
});

// ── Filter State ──
class ExploreFilter {
  final String search;
  final String type;
  final String sortBy;

  const ExploreFilter({this.search = '', this.type = 'all', this.sortBy = 'ranking'});

  ExploreFilter copyWith({String? search, String? type, String? sortBy}) {
    return ExploreFilter(
      search: search ?? this.search,
      type: type ?? this.type,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final exploreFilterProvider = StateProvider<ExploreFilter>((ref) => const ExploreFilter());

// ── Universities List ──
final universitiesProvider =
    StateNotifierProvider<UniversitiesNotifier, UiState<List<UniversityModel>>>((ref) {
  final repository = ref.watch(exploreRepositoryProvider);
  final filter = ref.watch(exploreFilterProvider);
  final notifier = UniversitiesNotifier(repository);
  notifier.loadUniversities(filter);
  return notifier;
});

class UniversitiesNotifier extends StateNotifier<UiState<List<UniversityModel>>> {
  final ExploreRepository _repository;

  UniversitiesNotifier(this._repository) : super(const UiState.initial());

  Future<void> loadUniversities(ExploreFilter filter) async {
    state = const UiState.loading();
    final result = await _repository.getUniversities(
      search: filter.search.isEmpty ? null : filter.search,
      type: filter.type,
      sortBy: filter.sortBy,
    );
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }
}

// ── Single University Detail ──
final universityDetailProvider =
    FutureProvider.family<UniversityModel?, String>((ref, id) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final result = await repository.getUniversityById(id);
  return result.dataOrNull;
});