import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

/// FR1 — POST /auth/v1/token?grant_type=password and /auth/v1/signup
class AuthService {
  final _auth = Supabase.instance.client.auth;

  Session? get session => _auth.currentSession;
  User? get user => _auth.currentUser;
  Stream<AuthState> get changes => _auth.onAuthStateChange;

  Future<void> login(String email, String password) =>
      _auth.signInWithPassword(email: email, password: password);

  /// Returns true if the user is logged in right away, false if the
  /// backend asks for email confirmation first.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'group_code': AppConfig.groupCode,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return res.session != null;
  }

  Future<void> logout() => _auth.signOut();
}
