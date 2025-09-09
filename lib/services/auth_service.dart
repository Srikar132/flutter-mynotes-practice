import 'package:firebase_auth/firebase_auth.dart';


class AuthService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }


  /// Signs out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Sends an email verification link to the user's email address.
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    await user?.sendEmailVerification();
  }

   Future<void> sendPasswordResetEmail({required String email}) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> refreshUser() async {
    await _firebaseAuth.currentUser?.reload();
  }


Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // update displayName if provided
      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName);
      }

      // send verification email
      await result.user?.sendEmailVerification();

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Login with email + password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // logout
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}