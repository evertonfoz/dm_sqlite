import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool signUpCalled = false;
  bool signInCalled = false;
  bool signOutCalled = false;
  bool resetPasswordCalled = false;
  
  bool shouldThrow = false;
  User? mockUser;
  Session? mockSession;

  String? lastEmail;
  String? lastPassword;

  @override
  User? get currentUser => mockUser;

  @override
  Session? get currentSession => mockSession;

  @override
  Future<User?> signUp({required String email, required String password}) async {
    signUpCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw Exception('Erro no cadastro');
    return mockUser;
  }

  @override
  Future<User?> signIn({required String email, required String password}) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw Exception('Erro no login');
    return mockUser;
  }

  @override
  Future signOut() async {
    signOutCalled = true;
    if (shouldThrow) throw Exception('Erro no logout');
  }

  @override
  Future resetPassword({required String email}) async {
    resetPasswordCalled = true;
    lastEmail = email;
    if (shouldThrow) throw Exception('Erro na recuperação');
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late AuthController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockAuthRepository();
    controller = AuthController(repository: mockRepository);
  });

  group('AuthController Unit Tests', () {
    test('signUp deve definir isLoading como true e depois false, e atualizar o currentUser', () async {
      // Arrange
      final user = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
      mockRepository.mockUser = user;
      
      final states = <bool>[];
      controller.addListener(() {
        states.add(controller.isLoading);
      });

      // Act
      final result = await controller.signUp(email: 'teste@exemplo.com', password: 'senha123');

      // Assert
      expect(result, isTrue);
      expect(mockRepository.signUpCalled, isTrue);
      expect(controller.currentUser, user);
      expect(controller.errorMessage, isNull);
      expect(states, [true, false]);
    });

    test('signUp deve expor mensagem de erro caso ocorra falha', () async {
      // Arrange
      mockRepository.shouldThrow = true;

      // Act
      final result = await controller.signUp(email: 'teste@exemplo.com', password: 'senha123');

      // Assert
      expect(result, isFalse);
      expect(mockRepository.signUpCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, contains('Não foi possível criar a conta.'));
    });

    test('signIn deve definir isLoading como true e depois false, e atualizar o currentUser', () async {
      // Arrange
      final user = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
      mockRepository.mockUser = user;
      
      final states = <bool>[];
      controller.addListener(() {
        states.add(controller.isLoading);
      });

      // Act
      final result = await controller.signIn(email: 'teste@exemplo.com', password: 'senha123');

      // Assert
      expect(result, isTrue);
      expect(mockRepository.signInCalled, isTrue);
      expect(controller.currentUser, user);
      expect(controller.errorMessage, isNull);
      expect(states, [true, false]);
    });

    test('signIn deve expor mensagem de erro caso ocorra falha', () async {
      // Arrange
      mockRepository.shouldThrow = true;

      // Act
      final result = await controller.signIn(email: 'teste@exemplo.com', password: 'senha123');

      // Assert
      expect(result, isFalse);
      expect(mockRepository.signInCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, contains('Não foi possível entrar.'));
    });

    test('signOut deve redefinir o currentUser como nulo', () async {
      // Arrange
      final user = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
      mockRepository.mockUser = user;
      await controller.signUp(email: 'teste@exemplo.com', password: 'senha123'); // define estado inicial logado

      // Act
      await controller.signOut();

      // Assert
      expect(mockRepository.signOutCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, isNull);
    });

    test('resetPassword deve chamar o repositorio para enviar e-mail de recuperacao', () async {
      // Act
      final result = await controller.resetPassword(email: 'teste@exemplo.com');

      // Assert
      expect(result, isTrue);
      expect(mockRepository.resetPasswordCalled, isTrue);
      expect(mockRepository.lastEmail, 'teste@exemplo.com');
      expect(controller.errorMessage, isNull);
    });

    test('loadCurrentUser deve atualizar currentUser se houver usuario logado no repository', () {
      // Arrange
      final user = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
      mockRepository.mockUser = user;

      // Act
      controller.loadCurrentUser();

      // Assert
      expect(controller.currentUser, user);
      expect(controller.errorMessage, isNull);
    });

    test('loadCurrentUser deve limpar/definir currentUser como nulo se nao houver usuario no repository', () {
      // Arrange
      mockRepository.mockUser = null;

      // Act
      controller.loadCurrentUser();

      // Assert
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, isNull);
    });
  });
}
