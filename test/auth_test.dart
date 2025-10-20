import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logIn function', () async {
      final user = await provider.createUser(
        email: 'test@example.com',
        password: 'password',
      );
      expect(user.email, 'test@example.com');
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;

  
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({required String email, required String password})async  {
    if (!isInitialized) throw NotInitializedException();

    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> deleteUser() {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    _user = null;
    return Future.value();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == '') throw UserNotFoundAuthException();
    // Simulate sending a password reset email
    await Future.delayed(const Duration(seconds: 1));
    return Future.value();
  }

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async  {
    if (!isInitialized) throw NotInitializedException();

    if (email == 'srikar@gmail.com') throw UserNotFoundAuthException();
    if (password == 'password') throw WrongPasswordAuthException();

    const user = AuthUser(
      id: 'my_id',
      email: 'srikar@gmail.com',
      isEmailVerified: false,
    );
    _user = user;
    return user;
  }

  @override
  Future<void> logOut() {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    _user = null;
    return Future.value();
  }

  @override
  Future<AuthUser?> reloadUser() {
    if (!isInitialized) throw NotInitializedException();
    return Future.value(_user);
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    // Simulate sending a verification email
    return Future.delayed(const Duration(seconds: 1));
  }


  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    if (!isInitialized) throw NotInitializedException();
    if (toEmail == '') throw UserNotFoundAuthException();
    // Simulate sending a password reset email
    return Future.delayed(const Duration(seconds: 1));
  }
  
}