import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/presentation/pages/register_page.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool signUpCalled = false;
  String? lastEmail;
  String? lastPassword;
  bool shouldThrow = false;
  supabase.User? mockUser;

  @override
  Future<supabase.User?> signUp({required String email, required String password}) async {
    signUpCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw Exception('Erro no cadastro');
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
      home: RegisterPage(authController: authController),
    );
  }

  testWidgets('Deve renderizar os componentes da tela de cadastro corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Comece seu cadastro'), findsOneWidget);
    expect(find.text('Criar conta'), findsAtLeastNWidgets(1));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Confirmar senha'), findsOneWidget);
    expect(find.text('Já tenho uma conta'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro de validação ao submeter formulário vazio', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Clica no botão de criar conta
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pump();

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe uma senha.'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro ao informar e-mail inválido', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'emailinvalido');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pump();

    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro ao informar senha curta', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pump();

    expect(find.text('A senha deve ter pelo menos 6 caracteres.'), findsOneWidget);
  });

  testWidgets('Deve mostrar erro quando a confirmação de senha for diferente', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'senha123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar senha'), 'senha321');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pump();

    expect(find.text('As senhas não conferem.'), findsOneWidget);
  });

  testWidgets('Deve chamar signUp no controller ao enviar formulário válido', (WidgetTester tester) async {
    mockRepository.mockUser = supabase.User(
      id: '123',
      appMetadata: {},
      userMetadata: {},
      aud: 'aud',
      createdAt: DateTime.now().toIso8601String(),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'teste@exemplo.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'senha123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar senha'), 'senha123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(mockRepository.signUpCalled, isTrue);
    expect(mockRepository.lastEmail, 'teste@exemplo.com');
    expect(mockRepository.lastPassword, 'senha123');
  });

  testWidgets('Deve exibir banner de erro se o signUp falhar', (WidgetTester tester) async {
    mockRepository.shouldThrow = true;

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'teste@exemplo.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'senha123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar senha'), 'senha123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível criar a conta. Verifique os dados e tente novamente.'), findsOneWidget);
  });
}
