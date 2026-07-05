import 'package:flutter/material.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/presentation/pages/onboarding_page.dart';

class PublicArea extends StatelessWidget {
  final AuthController? authController;

  const PublicArea({super.key, this.authController});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      authController: authController,
    );
  }
}
