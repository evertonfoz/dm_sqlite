import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/presentation/pages/forgot_password_page.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool resetPasswordCalled = false;
  String? lastEmail;
  bool shouldThrow = false;

  @override
  Future resetPassword({required String email}) async {
    resetPasswordCalled = true;
    lastEmail = email;
    if (shouldThrow) throw Exception('Erro na recuperação');
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late AuthController authController;

  setUp(() {
    mockRepository = MockAuthRepository();
    authController = AuthController(repository: mockRepository);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ForgotPasswordPage(authController: authController),
    );
  }

  testWidgets('Deve renderizar os componentes da tela de recuperar senha corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Recuperar Senha'), findsOneWidget);
    expect(find.text('Insira o e-mail cadastrado e enviaremos as instruções para a redefinição da sua senha.'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Enviar Instruções'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro de validação ao enviar e-mail vazio', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar Instruções'));
    await tester.pump();

    expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro ao informar e-mail inválido', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'Digite seu e-mail'), 'emailinvalido');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar Instruções'));
    await tester.pump();

    expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
  });

  testWidgets('Deve chamar resetPassword no controller ao enviar formulário válido', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'Digite seu e-mail'), 'teste@exemplo.com');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar Instruções'));
    await tester.pumpAndSettle();

    expect(mockRepository.resetPasswordCalled, isTrue);
    expect(mockRepository.lastEmail, 'teste@exemplo.com');
  });
}
