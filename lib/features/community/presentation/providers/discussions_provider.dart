import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';

// ── Models ──

class DiscussionModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String category;
  final String? universityId;
  final int replyCount;
  final DateTime createdAt;

  const DiscussionModel({
    required this.id, required this.userId, required this.title, required this.body,
    required this.category, this.universityId, this.replyCount = 0, required this.createdAt,
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) => DiscussionModel(
    id: json['id'], userId: json['user_id'], title: json['title'], body: json['body'],
    category: json['category'] ?? 'general', universityId: json['university_id'],
    replyCount: json['reply_count'] ?? 0, createdAt: DateTime.parse(json['created_at']),
  );

  String get categoryLabel {
    switch (category) {
      case 'admissions': return '🎓 Admissions';
      case 'academics': return '📚 Academics';
      case 'campus_life': return '🏫 Campus Life';
      case 'career': return '💼 Career';
      case 'test_prep': return '📝 Test Prep';
      default: return '💬 General';
    }
  }
}

class ReplyModel {
  final String id;
  final String discussionId;
  final String userId;
  final String body;
  final DateTime createdAt;

  const ReplyModel({required this.id, required this.discussionId, required this.userId, required this.body, required this.createdAt});

  factory ReplyModel.fromJson(Map<String, dynamic> json) => ReplyModel(
    id: json['id'], discussionId: json['discussion_id'], userId: json['user_id'],
    body: json['body'], createdAt: DateTime.parse(json['created_at']),
  );
}

// ── Constants ──

const discussionCategories = {
  'general': '💬 General',
  'admissions': '🎓 Admissions',
  'academics': '📚 Academics',
  'campus_life': '🏫 Campus Life',
  'career': '💼 Career',
  'test_prep': '📝 Test Prep',
};

// ── Providers ──

final discussionCategoryFilter = StateProvider<String?>((ref) => null);

final discussionsProvider = StateNotifierProvider<DiscussionsNotifier, UiState<List<DiscussionModel>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final notifier = DiscussionsNotifier(client);
  notifier.load();
  return notifier;
});

final filteredDiscussionsProvider = Provider<List<DiscussionModel>>((ref) {
  final all = ref.watch(discussionsProvider).dataOrNull ?? [];
  final cat = ref.watch(discussionCategoryFilter);
  if (cat == null) return all;
  return all.where((d) => d.category == cat).toList();
});

final discussionRepliesProvider = StateNotifierProvider.family<RepliesNotifier, UiState<List<ReplyModel>>, String>(
  (ref, discussionId) {
    final client = ref.watch(supabaseClientProvider);
    final notifier = RepliesNotifier(client, discussionId);
    notifier.load();
    return notifier;
  },
);

class DiscussionsNotifier extends StateNotifier<UiState<List<DiscussionModel>>> {
  final SupabaseClient _client;
  DiscussionsNotifier(this._client) : super(const UiState.initial());

  Future<void> load() async {
    state = const UiState.loading();
    try {
      final data = await _client.from('discussions').select().order('created_at', ascending: false);
      state = UiState.success(data.map<DiscussionModel>((e) => DiscussionModel.fromJson(e)).toList());
    } catch (e) {
      state = UiState.error('Failed to load discussions: $e');
    }
  }

  Future<bool> create({required String title, required String body, required String category}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await _client.from('discussions').insert({'user_id': userId, 'title': title, 'body': body, 'category': category});
      await load();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> delete(String id) async {
    try {
      await _client.from('discussions').delete().eq('id', id);
      await load();
      return true;
    } catch (e) { return false; }
  }
}

class RepliesNotifier extends StateNotifier<UiState<List<ReplyModel>>> {
  final SupabaseClient _client;
  final String _discussionId;
  RepliesNotifier(this._client, this._discussionId) : super(const UiState.initial());

  Future<void> load() async {
    state = const UiState.loading();
    try {
      final data = await _client.from('discussion_replies').select().eq('discussion_id', _discussionId).order('created_at');
      state = UiState.success(data.map<ReplyModel>((e) => ReplyModel.fromJson(e)).toList());
    } catch (e) {
      state = UiState.error('Failed to load replies: $e');
    }
  }

  Future<bool> addReply(String body) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await _client.from('discussion_replies').insert({'discussion_id': _discussionId, 'user_id': userId, 'body': body});
      await load();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> deleteReply(String id) async {
    try {
      await _client.from('discussion_replies').delete().eq('id', id);
      await load();
      return true;
    } catch (e) { return false; }
  }
}