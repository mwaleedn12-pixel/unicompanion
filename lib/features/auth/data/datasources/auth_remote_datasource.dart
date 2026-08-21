import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';

class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource(this._client);

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String fullName) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // Create user profile in database
    if (response.user != null) {
      await _client.from('user_profiles').upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'user_type': AppConstants.userTypeFsc,
        'onboarding_completed': false,
      });
    }

    return response;
  }

  Future<AuthResponse> signInWithGoogle() async {
    const webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) throw Exception('No ID token found');

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    // Create profile if first time
    if (response.user != null) {
      final existing = await _client
          .from('user_profiles')
          .select('id')
          .eq('id', response.user!.id)
          .maybeSingle();

      if (existing == null) {
        await _client.from('user_profiles').insert({
          'id': response.user!.id,
          'full_name': googleUser.displayName ?? '',
          'user_type': AppConstants.userTypeFsc,
          'onboarding_completed': false,
          'avatar_url': googleUser.photoUrl,
        });
      }
    }

    return response;
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}