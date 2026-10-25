import 'package:blooddonor/core/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Native Google sign-in exchanged for a Supabase session (S0-T5 test only).
class GoogleAuthService {
  const new(this._supabase);

  final SupabaseClient _supabase;
  static bool _initialized = false;

  Future<void> signIn() async {
    final google = GoogleSignIn.instance;
    if (!_initialized) {
      await google.initialize(serverClientId: AppConfig.googleWebClientId);
      _initialized = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('No ID token from Google');
    }
    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _supabase.auth.signOut();
  }
}
