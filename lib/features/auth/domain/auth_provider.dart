import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _subscription = _authService.authStateChanges.listen((user) {
      currentUser = user;
      isInitializing = false;
      notifyListeners();
    });
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _subscription;

  User? currentUser;
  bool isInitializing = true;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => currentUser != null;
  String get displayName => currentUser?.displayName?.trim().isNotEmpty == true
      ? currentUser!.displayName!
      : 'Mona';
  String get email => currentUser?.email ?? '';

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () => _authService.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () => _authService.register(name: name, email: email, password: password),
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    return _runAuthAction(() => _authService.sendPasswordReset(email));
  }

  Future<void> logout() => _authService.logout();

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<Object?> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
