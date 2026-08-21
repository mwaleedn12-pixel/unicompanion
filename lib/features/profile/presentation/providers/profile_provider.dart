import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../../home/presentation/providers/home_provider.dart';

final profileActionProvider = StateNotifierProvider<ProfileActionNotifier, UiState<void>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileActionNotifier(client);
});

class ProfileActionNotifier extends StateNotifier<UiState<void>> {
  final SupabaseClient _client;
  ProfileActionNotifier(this._client) : super(const UiState.initial());

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = const UiState.loading();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = const UiState.error('Not logged in');
        return false;
      }
      await _client.from('user_profiles').update(data).eq('id', userId);
      state = const UiState.success(null);
      return true;
    } catch (e) {
      state = UiState.error('Failed to update: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await LocalStorageService.clear();
  }
}