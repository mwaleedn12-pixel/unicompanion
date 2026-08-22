import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/datasources/explore_remote_datasource.dart';
import '../../data/models/university_model.dart';
import '../../data/models/program_model.dart';
import '../../data/models/campus_model.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/repositories/explore_repository.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ExploreRepositoryImpl(ExploreRemoteDatasource(client));
});

// ══════════════════════════════════════════════════
// Universities
// ══════════════════════════════════════════════════

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

final universityDetailProvider =
    FutureProvider.family<UniversityModel?, String>((ref, id) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final result = await repository.getUniversityById(id);
  return result.dataOrNull;
});

// ══════════════════════════════════════════════════
// Programs (Module 27 + 28)
// ══════════════════════════════════════════════════

class ProgramFilter {
  final String search;
  final String field;
  final String degreeLevel;

  const ProgramFilter({this.search = '', this.field = 'all', this.degreeLevel = 'all'});

  ProgramFilter copyWith({String? search, String? field, String? degreeLevel}) {
    return ProgramFilter(
      search: search ?? this.search,
      field: field ?? this.field,
      degreeLevel: degreeLevel ?? this.degreeLevel,
    );
  }
}

final programFilterProvider = StateProvider<ProgramFilter>((ref) => const ProgramFilter());

final programsProvider =
    StateNotifierProvider<ProgramsNotifier, UiState<List<ProgramModel>>>((ref) {
  final repository = ref.watch(exploreRepositoryProvider);
  final filter = ref.watch(programFilterProvider);
  final notifier = ProgramsNotifier(repository);
  notifier.loadPrograms(filter);
  return notifier;
});

class ProgramsNotifier extends StateNotifier<UiState<List<ProgramModel>>> {
  final ExploreRepository _repository;

  ProgramsNotifier(this._repository) : super(const UiState.initial());

  Future<void> loadPrograms(ProgramFilter filter) async {
    state = const UiState.loading();
    final result = await _repository.getPrograms(
      search: filter.search.isEmpty ? null : filter.search,
      field: filter.field,
      degreeLevel: filter.degreeLevel,
    );
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }
}

// Programs for a specific university (used in university detail)
final universityProgramsProvider =
    FutureProvider.family<List<ProgramModel>, String>((ref, universityId) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final result = await repository.getProgramsByUniversity(universityId);
  return result.dataOrNull ?? [];
});

// ══════════════════════════════════════════════════
// Campuses (Module 29)
// ══════════════════════════════════════════════════

final campusCityFilterProvider = StateProvider<String>((ref) => 'all');

final campusesProvider =
    StateNotifierProvider<CampusesNotifier, UiState<List<CampusModel>>>((ref) {
  final repository = ref.watch(exploreRepositoryProvider);
  final city = ref.watch(campusCityFilterProvider);
  final notifier = CampusesNotifier(repository);
  notifier.loadCampuses(city: city);
  return notifier;
});

class CampusesNotifier extends StateNotifier<UiState<List<CampusModel>>> {
  final ExploreRepository _repository;

  CampusesNotifier(this._repository) : super(const UiState.initial());

  Future<void> loadCampuses({String city = 'all'}) async {
    state = const UiState.loading();
    final result = await _repository.getCampuses(city: city == 'all' ? null : city);
    result.when(
      success: (data) => state = UiState.success(data),
      failure: (msg) => state = UiState.error(msg),
    );
  }
}

// Campuses for a specific university (used in university detail)
final universityCampusesProvider =
    FutureProvider.family<List<CampusModel>, String>((ref, universityId) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final result = await repository.getCampusesByUniversity(universityId);
  return result.dataOrNull ?? [];
});

// Available cities for the filter
final campusCitiesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final result = await repository.getCampusCities();
  return result.dataOrNull ?? [];
});