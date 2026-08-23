import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';

// ── Model ──

class ReviewModel {
  final String id;
  final String userId;
  final String universityId;
  final int rating;
  final String? title;
  final String? body;
  final String? pros;
  final String? cons;
  final bool isCurrentStudent;
  final DateTime createdAt;
  final String? userName; // joined from auth

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.universityId,
    required this.rating,
    this.title,
    this.body,
    this.pros,
    this.cons,
    this.isCurrentStudent = false,
    required this.createdAt,
    this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      universityId: json['university_id'],
      rating: json['rating'],
      title: json['title'],
      body: json['body'],
      pros: json['pros'],
      cons: json['cons'],
      isCurrentStudent: json['is_current_student'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
    );
  }
}

// ── Provider ──

final universityReviewsProvider = StateNotifierProvider.family<ReviewsNotifier, UiState<List<ReviewModel>>, String>(
  (ref, universityId) {
    final client = ref.watch(supabaseClientProvider);
    final notifier = ReviewsNotifier(client, universityId);
    notifier.load();
    return notifier;
  },
);

/// Average rating for a university (derived)
final universityRatingProvider = Provider.family<double, String>((ref, universityId) {
  final state = ref.watch(universityReviewsProvider(universityId));
  final reviews = state.dataOrNull ?? [];
  if (reviews.isEmpty) return 0;
  return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
});

/// Whether current user already reviewed this university
final hasReviewedProvider = Provider.family<bool, String>((ref, universityId) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return false;
  final reviews = ref.watch(universityReviewsProvider(universityId)).dataOrNull ?? [];
  return reviews.any((r) => r.userId == userId);
});

class ReviewsNotifier extends StateNotifier<UiState<List<ReviewModel>>> {
  final SupabaseClient _client;
  final String _universityId;

  ReviewsNotifier(this._client, this._universityId) : super(const UiState.initial());

  Future<void> load() async {
    state = const UiState.loading();
    try {
      final data = await _client
          .from('university_reviews')
          .select()
          .eq('university_id', _universityId)
          .order('created_at', ascending: false);

      final reviews = data.map<ReviewModel>((e) => ReviewModel.fromJson(e)).toList();
      state = UiState.success(reviews);
    } catch (e) {
      state = UiState.error('Failed to load reviews: $e');
    }
  }

  Future<bool> addReview({
    required int rating,
    String? title,
    String? body,
    String? pros,
    String? cons,
    bool isCurrentStudent = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _client.from('university_reviews').insert({
        'user_id': userId,
        'university_id': _universityId,
        'rating': rating,
        'title': title,
        'body': body,
        'pros': pros,
        'cons': cons,
        'is_current_student': isCurrentStudent,
      });
      await load();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReview(String id) async {
    try {
      await _client.from('university_reviews').delete().eq('id', id);
      await load();
      return true;
    } catch (e) {
      return false;
    }
  }
}