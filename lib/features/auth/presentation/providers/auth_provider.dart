import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Repository Provider ──
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final datasource = AuthRemoteDatasource(client);
  return AuthRepositoryImpl(datasource);
});

// ── Auth State ──
final authStateProvider =
    StateNotifierProvider<AuthNotifier, UiState<UserEntity>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<UiState<UserEntity>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const UiState.initial());

  Future<void> signInWithEmail(String email, String password) async {
    state = const UiState.loading();
    final result = await _repository.signInWithEmail(email, password);
    result.when(
      success: (user) => state = UiState.success(user),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    state = const UiState.loading();
    final result = await _repository.signUpWithEmail(email, password, fullName);
    result.when(
      success: (user) => state = UiState.success(user),
      failure: (msg) => state = UiState.error(msg),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const UiState.loading();
    final result = await _repository.signInWithGoogle();
    result.when(
      success: (user) => state = UiState.success(user),
      failure: (msg) => state = UiState.error(msg),
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
    state = const UiState.initial();
  }

  void resetState() {
    state = const UiState.initial();
  }
}

// ── Reset Password State (separate so login state doesn't reset) ──
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