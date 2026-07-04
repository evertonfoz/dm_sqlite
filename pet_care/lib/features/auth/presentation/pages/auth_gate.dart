import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:pet_care/features/auth/presentation/pages/onboarding_page.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_list_page.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';

class AuthGate extends StatefulWidget {
  final SupabaseClient? supabaseClient;
  final TutorController? tutorController;

  const AuthGate({super.key, this.supabaseClient, this.tutorController});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _authController;
  late final SupabaseClient _client;

  @override
  void initState() {
    super.initState();
    _client = widget.supabaseClient ?? Supabase.instance.client;
    _authController = AuthController(SupabaseAuthRepository(supabaseClient: _client));
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final currentSession = _client.auth.currentSession;
          if (currentSession != null) {
            return TutorListPage(
              controller: widget.tutorController,
              authController: _authController,
            );
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
              ),
            ),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return TutorListPage(
            controller: widget.tutorController,
            authController: _authController,
          );
        } else {
          return OnboardingPage(authController: _authController);
        }
      },
    );
  }
}
