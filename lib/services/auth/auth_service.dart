import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
 static AuthService? _instance;

  AuthService._internal(this.provider);

  // Singleton pattern with factory constructor
  factory AuthService.firebase() {
    _instance ??= AuthService._internal(FirebaseAuthProvider());
    return _instance!;
  }


  @override
  Future<void> initialize() => provider.initialize();

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) => provider.createUser(email: email, password: password);

  @override
  Future<AuthUser?> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> forgotPassword({required String email}) =>
      provider.forgotPassword(email: email);

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);

  @override
  Future<void> deleteUser() => provider.deleteUser();

  @override
  Future<AuthUser?> reloadUser() => provider.reloadUser();
  
}
