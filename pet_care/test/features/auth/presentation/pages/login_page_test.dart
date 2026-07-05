import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/presentation/pages/login_page.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool signInCalled = false;
  String? lastEmail;
  String? lastPassword;
  bool shouldThrow = false;
  supabase.User? mockUser;

  @override
  Future<supabase.User?> signIn({required String email, required String password}) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw Exception('Erro no login');
    return mockUser;
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
      home: LoginPage(authController: authController),
    );
  }

  testWidgets('Deve renderizar os componentes da tela de login corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Faça login para gerenciar as informações de seus pets.'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Não tem uma conta? '), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro de validação ao tentar logar com campos vazios', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
    expect(find.text('Por favor, insira sua senha'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro ao informar e-mail inválido', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'Digite seu e-mail'), 'emailinvalido');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
  });

  testWidgets('Deve chamar signIn no controller ao enviar formulário válido', (WidgetTester tester) async {
    mockRepository.mockUser = supabase.User(
      id: '123',
      appMetadata: {},
      userMetadata: {},
      aud: 'aud',
      createdAt: DateTime.now().toIso8601String(),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'Digite seu e-mail'), 'teste@exemplo.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Digite sua senha'), 'senha123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(mockRepository.signInCalled, isTrue);
    expect(mockRepository.lastEmail, 'teste@exemplo.com');
    expect(mockRepository.lastPassword, 'senha123');
  });
}
