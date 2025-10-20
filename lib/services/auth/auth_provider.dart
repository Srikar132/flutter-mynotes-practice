import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<void> initialize();
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<AuthUser?> logIn({required String email, required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> forgotPassword({required String email});
  Future<void> sendPasswordReset({required String toEmail});
  Future<void> deleteUser();
  Future<AuthUser?> reloadUser();
}
