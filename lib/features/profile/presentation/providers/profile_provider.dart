import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../../academics/presentation/providers/assignment_provider.dart';
import '../../../applications/presentation/providers/application_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';

final remindersEnabledProvider = StateNotifierProvider<RemindersEnabledNotifier, bool>((ref) {
  return RemindersEnabledNotifier(ref);
});

class RemindersEnabledNotifier extends StateNotifier<bool> {
  final Ref _ref;
  RemindersEnabledNotifier(this._ref) : super(LocalStorageService.remindersEnabled);

  Future<void> setEnabled(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        state = false;
        await LocalStorageService.setRemindersEnabled(false);
        return;
      }
      state = value;
      await LocalStorageService.setRemindersEnabled(value);
      await _ref.read(assignmentsProvider.notifier).load();
      await _ref.read(applicationsProvider.notifier).load();
      return;
    }

    await NotificationService.instance.cancelAll();
    state = value;
    await LocalStorageService.setRemindersEnabled(value);
  }
}

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