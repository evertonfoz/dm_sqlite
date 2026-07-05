import 'package:flutter/material.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_list_page.dart';

class AuthenticatedArea extends StatelessWidget {
  final TutorController? tutorController;
  final AuthController? authController;

  const AuthenticatedArea({
    super.key,
    this.tutorController,
    this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return TutorListPage(
      controller: tutorController,
      authController: authController,
    );
  }
}
