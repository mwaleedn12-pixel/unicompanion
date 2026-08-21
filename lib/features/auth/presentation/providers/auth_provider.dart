import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final datasource = AuthRemoteDatasource(client);
  return AuthRepositoryImpl(datasource);
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, UiState<UserEntity>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  return AuthNotifier(repository, client);
});

class AuthNotifier extends StateNotifier<UiState<UserEntity>> {
  final AuthRepository _repository;
  final dynamic _client;

  AuthNotifier(this._repository, this._client) : super(const UiState.initial());

  /// After login/signup, check if onboarding is already done in Supabase
  Future<void> _syncOnboardingStatus(String userId) async {
    try {
      final data = await _client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', userId)
          .maybeSingle();

      if (data != null && data['onboarding_completed'] == true) {
        await LocalStorageService.setOnboardingComplete(true);
        final userType = await _client
            .from('user_profiles')
            .select('user_type')
            .eq('id', userId)
            .maybeSingle();
        if (userType != null && userType['user_type'] != null) {
          await LocalStorageService.setUserType(userType['user_type']);
        }
      }
    } catch (_) {}
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const UiState.loading();
    final result = await _repository.signInWithEmail(email, password);
    await result.when(
      success: (user) async {
        await _syncOnboardingStatus(user.id);
        state = UiState.success(user);
      },
      failure: (msg) async {
        state = UiState.error(msg);
      },
    );
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    state = const UiState.loading();
    final result = await _repository.signUpWithEmail(email, password, fullName);
    await result.when(
      success: (user) async {
        state = UiState.success(user);
      },
      failure: (msg) async {
        state = UiState.error(msg);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = const UiState.loading();
    final result = await _repository.signInWithGoogle();
    await result.when(
      success: (user) async {
        await _syncOnboardingStatus(user.id);
        state = UiState.success(user);
      },
      failure: (msg) async {
        state = UiState.error(msg);
      },
    );
  }

  Future<void> resetPassword(String email) async {
    state = const UiState.loading();
    final result = await _repository.resetPassword(email);
    result.when(
      success: (_) => state = const UiState.initial(),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    await LocalStorageService.clear();
    state = const UiState.initial();
  }

  void resetState() => state = const UiState.initial();
}

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, UiState<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordNotifier(repository);
});

class ResetPasswordNotifier extends StateNotifier<UiState<void>> {
  final AuthRepository _repository;

  ResetPasswordNotifier(this._repository) : super(const UiState.initial());

  Future<bool> resetPassword(String email) async {
    state = const UiState.loading();
    final result = await _repository.resetPassword(email);
    return result.when(
      success: (_) {
        state = const UiState.success(null);
        return true;
      },
      failure: (msg) {
        state = UiState.error(msg);
        return false;
      },
    );
  }

  void resetState() => state = const UiState.initial();
}