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

  /// Set right before `state` becomes success, so listeners (e.g. LoginScreen)
  /// know whether to route to onboarding or home for the account that just logged in.
  bool onboardingComplete = false;

  AuthNotifier(this._repository, this._client) : super(const UiState.initial());

  /// After login/signup, sync local cache with Supabase's actual onboarding
  /// state for THIS user — always overwrites, never leaves a stale value
  /// from a previously logged-in account. Returns true if onboarding is done.
  Future<bool> _syncOnboardingStatus(String userId) async {
    try {
      final data = await _client
          .from('user_profiles')
          .select('onboarding_completed, user_type')
          .eq('id', userId)
          .maybeSingle();

      final isComplete = data != null && data['onboarding_completed'] == true;
      await LocalStorageService.setOnboardingComplete(isComplete);

      if (isComplete && data['user_type'] != null) {
        await LocalStorageService.setUserType(data['user_type']);
      } else {
        // Clear any stale user_type left over from a different account.
        await LocalStorageService.clearUserType();
      }

      return isComplete;
    } catch (_) {
      return false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const UiState.loading();
    final result = await _repository.signInWithEmail(email, password);
    await result.when(
      success: (user) async {
        onboardingComplete = await _syncOnboardingStatus(user.id);
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
        onboardingComplete = false;
        await LocalStorageService.setOnboardingComplete(false);
        await LocalStorageService.clearUserType();
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
        onboardingComplete = await _syncOnboardingStatus(user.id);
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
    onboardingComplete = false;
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