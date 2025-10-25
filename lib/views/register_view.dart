import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import "package:mynotes/utils/ui_helpers.dart";
import 'package:mynotes/utils/validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthService _authService;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService.firebase();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle registration logic
  Future<void> _handleRegistration() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate inputs
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final confirmPasswordError = validateConfirmPassword(
      confirmPassword,
      password,
    );

    if (emailError != null) {
      NoteHelpers.showErrorSnackBar(context, emailError);
      return;
    }
    if (passwordError != null) {
      NoteHelpers.showErrorSnackBar(context, passwordError);
      return;
    }
    if (confirmPasswordError != null) {
      NoteHelpers.showErrorSnackBar(context, confirmPasswordError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to create the user
      await _authService.createUser(email: email, password: password);

      if (mounted) {
        NoteHelpers.showSuccessSnackBar(
          context,
          'Registration successful! Please verify your email.',
        );
      }

      // Send email verification
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
      }
    } on WeakPasswordAuthException {
      if (mounted) {
        NoteHelpers.showErrorSnackBar(context, 'The password provided is too weak.');
      }
    } on EmailAlreadyInUseAuthException {
      if (mounted) {
        NoteHelpers.showErrorSnackBar(
          context,
          'The account already exists for that email.',
        );
      }
    } on InvalidEmailAuthException {
      if (mounted) {
        NoteHelpers.showErrorSnackBar(context, 'The email address is not valid.');
      }
    } on GenericAuthException {
      if (mounted) {
        NoteHelpers.showErrorSnackBar(context, 'Failed to register. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        NoteHelpers.showErrorSnackBar(
          context,
          'An error occurred during registration. Please try again.',
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
            Icon(
              Icons.note_alt_outlined,
              size: 50,
              //colour to stylish blue
              color: Color(0xFF3B82F6),
            ),

            const SizedBox(height: 8),

            // Title of create your account
            const Text(
              'Create Your Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Join My Notes to start organizing your thoughts',
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
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password (min 6 characters)',
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

            const SizedBox(height: 20),

            // Confirm Password Field
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !_isLoading,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleRegistration(),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
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

            const SizedBox(height: 20),

            // Password Requirements Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withAlpha(26)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Password must be at least 6 characters long',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Register Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegistration,
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
                        Text(
                          'Creating Account...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 24),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Navigate to login screen
                          Navigator.pushReplacementNamed(context, loginRoute);
                        },
                  child: const Text(
                    'Sign In',
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
