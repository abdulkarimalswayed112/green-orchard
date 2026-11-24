import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_error.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();
  late final StreamSubscription<AuthState> _sub;

  bool loading = false;
  String? error;

  AuthProvider() {
    // Rebuilds the app on login, logout, token refresh or session expiry.
    _sub = _service.changes.listen((_) => notifyListeners());
  }

  bool get isLoggedIn => _service.session != null;
  String get email => _service.user?.email ?? '';
  String get fullName =>
      (_service.user?.userMetadata?['full_name'] as String?) ?? email;

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email.trim(), password));

  /// Returns null on success with an active session, or an info message
  /// (e.g. "confirm your email") when the account needs confirmation.
  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    String? info;
    final ok = await _run(() async {
      final loggedIn = await _service.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        phone: phone?.trim(),
      );
      if (!loggedIn) info = 'Account created. Check your email, then log in.';
    });
    if (!ok) throw Exception(error);
    return info;
  }

  Future<void> logout() => _service.logout();

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      error = friendlyError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
