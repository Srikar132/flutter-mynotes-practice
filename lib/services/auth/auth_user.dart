import 'package:firebase_auth/firebase_auth.dart'  show User;
import 'package:flutter/foundation.dart';

/*
 * A class representing an authenticated user.
 * and is immutable. i.e., its properties cannot be changed after creation.
 */
@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email,
        name: user.displayName,
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
      );
  
  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, name: $name, photoUrl: $photoUrl, isEmailVerified: $isEmailVerified)';
  }
}