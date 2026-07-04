import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/presentation/pages/onboarding_page.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Fake implements IAuthRepository {}

void main() {
  testWidgets('OnboardingPage renderiza elementos visuais corretamente', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    final controller = AuthController(mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(authController: controller),
      ),
    );

    // Assert
    expect(find.text('Pet Care'), findsOneWidget);
    expect(find.text('Criar Conta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsOneWidget);
  });
}
