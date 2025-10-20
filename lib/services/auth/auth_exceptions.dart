// Login exceptions
class UserNotFoundAuthException implements Exception {
  @override
  String toString() => 'User not found. Please check your email address.';
}

class WrongPasswordAuthException implements Exception {
  @override
  String toString() => 'Wrong password. Please try again.';
}

class InvalidEmailAuthException implements Exception {
  @override
  String toString() => 'Invalid email address format.';
}

class UserDisabledAuthException implements Exception {
  @override
  String toString() => 'This user account has been disabled.';
}

class TooManyRequestsAuthException implements Exception {
  @override
  String toString() => 'Too many failed attempts. Please try again later.';
}

class InvalidCredentialAuthException implements Exception {
  @override
  String toString() => 'Invalid credentials. Please try again.';
}

// Register exceptions
class EmailAlreadyInUseAuthException implements Exception {
  @override
  String toString() => 'This email address is already registered.';
}

class WeakPasswordAuthException implements Exception {
  @override
  String toString() => 'Password is too weak. Please use a stronger password.';
}

class OperationNotAllowedAuthException implements Exception {
  @override
  String toString() => 'This operation is not allowed. Please contact support.';
}

// Network and generic exceptions
class NetworkErrorAuthException implements Exception {
  @override
  String toString() => 'Network error. Please check your internet connection and try again.';
}

class GenericAuthException implements Exception {
  @override
  String toString() => 'Authentication error. Please try again later.';
}

class UserNotLoggedInAuthException implements Exception {
  @override
  String toString() => 'User is not logged in.';
}