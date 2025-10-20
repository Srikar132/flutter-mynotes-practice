import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import "package:mynotes/utils/ui_helpers.dart";
import 'package:mynotes/utils/validators.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthService _authService;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService.firebase();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login logic
  Future<void> _handleLogin() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate inputs
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null) {
      showErrorSnackBar(context, emailError);
      return;
    }
    if (passwordError != null) {
      showErrorSnackBar(context, passwordError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logIn(email: email, password: password);

      if (mounted) {
        showSuccessSnackBar(context, 'Welcome back! Login successful.');
      }

      // wait a bit here
      await Future.delayed(const Duration(seconds: 1));

      // send email verfication if not verified
      if (_authService.currentUser != null &&
          !_authService.currentUser!.isEmailVerified) {
        if (mounted) {
          showErrorSnackBar(
            context,
            'Please verify your email before signing in.',
          );
        }
        // navigate to verify email view
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
        }
      } else {
        // Navigate to main app screen
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(homeRoute, (route) => false);
        }
      }
    } on UserNotFoundAuthException {
      if (mounted) {
        showErrorSnackBar(
          context,
          'No user found for that email. Please register first.',
        );
      }
    } on WrongPasswordAuthException {
      if (mounted) {
        showErrorSnackBar(context, 'Incorrect password. Please try again.');
      }
    } on InvalidEmailAuthException {
      if (mounted) {
        showErrorSnackBar(context, 'The email address is not valid.');
      }
    } on UserDisabledAuthException {
      if (mounted) {
        showErrorSnackBar(context, 'This account has been disabled.');
      }
    } on TooManyRequestsAuthException {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Too many failed attempts. Please try again later.',
        );
      }
    } on OperationNotAllowedAuthException {
      if (mounted) {
        showErrorSnackBar(
          context,
          'This operation is not allowed. Please contact support.',
        );
      }
    } on GenericAuthException {
      if (mounted) {
        showErrorSnackBar(context, 'Authentication error. Please try again.');
      }
    } on NetworkErrorAuthException {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Network error. Please check your internet connection and try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle forgot password
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showErrorSnackBar(context, 'Please enter your email address first.');
      return;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      showErrorSnackBar(context, emailError);
      return;
    }

    try {
      await _authService.sendPasswordReset(toEmail: email);

      if (mounted) {
        showSuccessSnackBar(
          context,
          'Password reset email sent. Check your inbox.',
        );
      }
    } on UserNotFoundAuthException {
      if (mounted) {
        showErrorSnackBar(
          context,
          'No user found for that email. Please register first.',
        );
      }
    } on GenericAuthException {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Failed to send password reset email. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'An error occurred. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Welcome Section
            const SizedBox(height: 80),

            // Icon
            Icon(Icons.note_alt_sharp, size: 50, color: Color(0xFF3B82F6)),

            const SizedBox(height: 32),

            // Welcome Text
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'Sign in to continue to My Notes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Email Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Remember Me & Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                      child: const Text('Remember me'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Signing In...', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : const Text('Sign In', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 24),

            // Divider
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 24),

            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Navigate to register screen
                          Navigator.pushReplacementNamed(
                            context,
                            registerRoute,
                          );
                        },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
