import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';

class MockAuthRepository extends Fake implements IAuthRepository {
  bool signUpCalled = false;
  bool signInCalled = false;
  bool signOutCalled = false;
  bool resetPasswordCalled = false;
  bool checkSessionCalled = false;
  
  bool shouldThrow = false;
  User? mockUser;
  bool mockSessionResult = false;

  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw Exception('Erro no cadastro');
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw Exception('Erro no login');
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    if (shouldThrow) throw Exception('Erro no logout');
  }

  @override
  Future<void> resetPassword({required String email}) async {
    resetPasswordCalled = true;
    lastEmail = email;
    if (shouldThrow) throw Exception('Erro na recuperação');
  }

  @override
  User? getCurrentUser() {
    return mockUser;
  }

  @override
  Future<bool> checkSession() async {
    checkSessionCalled = true;
    if (shouldThrow) throw Exception('Erro na sessão');
    return mockSessionResult;
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late AuthController controller;

  setUp(() {
    mockRepository = MockAuthRepository();
    controller = AuthController(mockRepository);
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
      await controller.signUp('teste@exemplo.com', 'senha123');

      // Assert
      expect(mockRepository.signUpCalled, isTrue);
      expect(controller.currentUser, user);
      expect(controller.errorMessage, isNull);
      expect(states, [true, false]);
    });

    test('signUp deve expor mensagem de erro caso ocorra falha', () async {
      // Arrange
      mockRepository.shouldThrow = true;

      // Act
      await controller.signUp('teste@exemplo.com', 'senha123');

      // Assert
      expect(mockRepository.signUpCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, 'Erro no cadastro');
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
      await controller.signIn('teste@exemplo.com', 'senha123');

      // Assert
      expect(mockRepository.signInCalled, isTrue);
      expect(controller.currentUser, user);
      expect(controller.errorMessage, isNull);
      expect(states, [true, false]);
    });

    test('signIn deve expor mensagem de erro caso ocorra falha', () async {
      // Arrange
      mockRepository.shouldThrow = true;

      // Act
      await controller.signIn('teste@exemplo.com', 'senha123');

      // Assert
      expect(mockRepository.signInCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, 'Erro no login');
    });

    test('signOut deve redefinir o currentUser como nulo', () async {
      // Arrange
      controller.signUp('teste@exemplo.com', 'senha123'); // define estado inicial logado

      // Act
      await controller.signOut();

      // Assert
      expect(mockRepository.signOutCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, isNull);
    });

    test('resetPassword deve chamar o repositorio para enviar e-mail de recuperacao', () async {
      // Act
      await controller.resetPassword('teste@exemplo.com');

      // Assert
      expect(mockRepository.resetPasswordCalled, isTrue);
      expect(mockRepository.lastEmail, 'teste@exemplo.com');
      expect(controller.errorMessage, isNull);
    });

    test('checkSession deve atualizar currentUser se houver sessao ativa', () async {
      // Arrange
      final user = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
      mockRepository.mockUser = user;
      mockRepository.mockSessionResult = true;

      // Act
      await controller.checkSession();

      // Assert
      expect(mockRepository.checkSessionCalled, isTrue);
      expect(controller.currentUser, user);
      expect(controller.errorMessage, isNull);
    });

    test('checkSession deve limpar currentUser se nao houver sessao ativa', () async {
      // Arrange
      mockRepository.mockSessionResult = false;

      // Act
      await controller.checkSession();

      // Assert
      expect(mockRepository.checkSessionCalled, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, isNull);
    });
  });
}
