import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:mynotes/firebase_options.dart';

import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';

class FirebaseAuthProvider implements AuthProvider {
  FirebaseAuth? _firebaseAuth;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      try {
        Firebase.app();
        debugPrint('Firebase already initialized');
      } catch (e) {
        // Firebase not initialized, so initialize it
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('Firebase initialized successfully');
      }
      
      _firebaseAuth = FirebaseAuth.instance;
      _isInitialized = true;
      
      // Enable network for Firebase Auth (in case it was disabled)
      await _firebaseAuth?.authStateChanges().first;
      
    } catch (e) {
      print('Firebase initialization error: $e');
      _isInitialized = false;
      throw GenericAuthException();
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized || _firebaseAuth == null) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    _ensureInitialized();
    final user = _firebaseAuth?.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();
    
    try {
      final userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return AuthUser.fromFirebase(user);
      } else {
        throw GenericAuthException();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase createUser error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          throw EmailAlreadyInUseAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'operation-not-allowed':
          throw OperationNotAllowedAuthException();
        case 'weak-password':
          throw WeakPasswordAuthException();
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected createUser error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();
    
    try {
      final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = userCredential.user;
      
      if (user != null) {
        return AuthUser.fromFirebase(user);
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase logIn error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'wrong-password':
          throw WrongPasswordAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'user-disabled':
          throw UserDisabledAuthException();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        case 'operation-not-allowed':
          throw OperationNotAllowedAuthException();
        case 'invalid-credential':
          throw InvalidCredentialAuthException();
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        case 'internal-error':
          throw GenericAuthException();
        default:
          print('Unhandled Firebase Auth error: ${e.code}');
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected logIn error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    _ensureInitialized();
    
    try {
      final user = _firebaseAuth?.currentUser;
      if (user != null) {
        await _firebaseAuth!.signOut();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase logOut error: ${e.code} - ${e.message}');
      throw GenericAuthException();
    } catch (e) {
      print('Unexpected logOut error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    _ensureInitialized();
    
    try {
      final user = _firebaseAuth?.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase sendEmailVerification error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected sendEmailVerification error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    _ensureInitialized();
    
    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      print('Firebase forgotPassword error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected forgotPassword error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    _ensureInitialized();
    
    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: toEmail.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      print('Firebase sendPasswordReset error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected sendPasswordReset error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> deleteUser() async {
    _ensureInitialized();
    
    try {
      final user = _firebaseAuth?.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase deleteUser error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'requires-recent-login':
          throw InvalidCredentialAuthException();
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected deleteUser error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser?> reloadUser() async {
    _ensureInitialized();
    
    try {
      final user = _firebaseAuth?.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = _firebaseAuth?.currentUser;
        if (refreshedUser != null) {
          return AuthUser.fromFirebase(refreshedUser);
        } else {
          throw UserNotLoggedInAuthException();
        }
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase reloadUser error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'network-request-failed':
          throw NetworkErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      print('Unexpected reloadUser error: $e');
      throw GenericAuthException();
    }
  }
}