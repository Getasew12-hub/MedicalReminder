import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error, AuthAction.login));
    }
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error, AuthAction.register));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error, AuthAction.passwordReset));
    }
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  Future<void> logout() => _auth.signOut();

  String _messageFor(FirebaseAuthException error, AuthAction action) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'user-not-found':
      case 'invalid-credential':
        if (action == AuthAction.passwordReset) {
          return 'No account exists with this email address.';
        }
        return 'We could not log you in. Check your email and password, then try again.';
      case 'wrong-password':
        return 'We could not log you in. Check your email and password, then try again.';
      case 'email-already-in-use':
        return 'We could not create your account because this email is already registered.';
      case 'weak-password':
        return 'We could not create your account. Please choose a password with at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'operation-not-allowed':
        if (action == AuthAction.register) {
          return 'Sign up is not enabled right now. Please try again later.';
        }
        return 'Login is not enabled right now. Please try again later.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment before trying again.';
      default:
        if (action == AuthAction.register) {
          return error.message ??
              'We could not create your account. Please try again.';
        }
        if (action == AuthAction.passwordReset) {
          return error.message ??
              'We could not send the password reset email. Please try again.';
        }
        return error.message ?? 'We could not log you in. Please try again.';
    }
  }
}

enum AuthAction { login, register, passwordReset }

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
