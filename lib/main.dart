import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/layout_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyNotesApp());
}

class MyNotesApp extends StatelessWidget {
  const MyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notion',
      debugShowCheckedModeBanner: false,
      theme: NotesTheme.lightTheme,
      darkTheme: NotesTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const FirebaseInitializationWrapper(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        homeRoute: (context) => const HomeView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute : (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

class FirebaseInitializationWrapper extends StatelessWidget {
  const FirebaseInitializationWrapper({super.key});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final user = AuthService.firebase().currentUser;

          if (user == null) {
            return const RegisterView();
          } else if (!user.isEmailVerified) {
            return const VerifyEmailView();
          } else {
            return const HomeView();
          }
          
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error initializing Firebase")),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}