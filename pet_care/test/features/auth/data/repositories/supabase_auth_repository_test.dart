import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/data/repositories/supabase_auth_repository.dart';

// Fake dinâmico usando noSuchMethod para evitar incompatibilidades de assinatura
class FakeGoTrueClient extends Fake implements GoTrueClient {
  bool signUpCalled = false;
  bool signInCalled = false;
  bool signOutCalled = false;
  bool resetPasswordCalled = false;
  User? mockUser;
  Session? mockSession;

  String? lastEmail;
  String? lastPassword;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName;
    
    if (memberName == #signUp) {
      signUpCalled = true;
      lastEmail = invocation.namedArguments[#email] as String?;
      lastPassword = invocation.namedArguments[#password] as String?;
      return Future.value(AuthResponse(session: mockSession, user: mockUser));
    }
    
    if (memberName == #signInWithPassword) {
      signInCalled = true;
      lastEmail = invocation.namedArguments[#email] as String?;
      lastPassword = invocation.namedArguments[#password] as String?;
      return Future.value(AuthResponse(session: mockSession, user: mockUser));
    }
    
    if (memberName == #signOut) {
      signOutCalled = true;
      return Future.value();
    }
    
    if (memberName == #resetPasswordForEmail) {
      resetPasswordCalled = true;
      // O email pode ser posicional (primeiro argumento) ou nomeado em algumas versões
      if (invocation.positionalArguments.isNotEmpty) {
        lastEmail = invocation.positionalArguments.first as String?;
      } else {
        lastEmail = invocation.namedArguments[#email] as String?;
      }
      return Future.value();
    }
    
    if (memberName == #currentUser) {
      return mockUser;
    }
    
    if (memberName == #currentSession) {
      return mockSession;
    }
    
    return super.noSuchMethod(invocation);
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final FakeGoTrueClient _auth;

  FakeSupabaseClient(this._auth);

  @override
  FakeGoTrueClient get auth => _auth;
}

void main() {
  late FakeGoTrueClient fakeGoTrueClient;
  late FakeSupabaseClient fakeSupabaseClient;
  late SupabaseAuthRepository repository;

  setUp(() {
    fakeGoTrueClient = FakeGoTrueClient();
    fakeSupabaseClient = FakeSupabaseClient(fakeGoTrueClient);
    repository = SupabaseAuthRepository(client: fakeSupabaseClient);
  });

  group('SupabaseAuthRepository Unit Tests', () {
    test('signUp deve chamar auth.signUp no cliente do Supabase', () async {
      // Arrange
      const email = 'teste@exemplo.com';
      const password = 'senha123';

      // Act
      await repository.signUp(email: email, password: password);

      // Assert
      expect(fakeGoTrueClient.signUpCalled, isTrue);
      expect(fakeGoTrueClient.lastEmail, email);
      expect(fakeGoTrueClient.lastPassword, password);
    });

    test('signIn deve chamar auth.signInWithPassword no cliente do Supabase', () async {
      // Arrange
      const email = 'teste@exemplo.com';
      const password = 'senha123';

      // Act
      await repository.signIn(email: email, password: password);

      // Assert
      expect(fakeGoTrueClient.signInCalled, isTrue);
      expect(fakeGoTrueClient.lastEmail, email);
      expect(fakeGoTrueClient.lastPassword, password);
    });

    test('signOut deve chamar auth.signOut no cliente do Supabase', () async {
      // Act
      await repository.signOut();

      // Assert
      expect(fakeGoTrueClient.signOutCalled, isTrue);
    });

    test('resetPassword deve chamar auth.resetPasswordForEmail no cliente do Supabase', () async {
      // Arrange
      const email = 'teste@exemplo.com';

      // Act
      await repository.resetPassword(email: email);

      // Assert
      expect(fakeGoTrueClient.resetPasswordCalled, isTrue);
      expect(fakeGoTrueClient.lastEmail, email);
    });

    test('getCurrentUser deve retornar o usuário atual do Supabase', () {
      // Arrange
      final expectedUser = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );
      fakeGoTrueClient.mockUser = expectedUser;

      // Act
      final result = repository.currentUser;

      // Assert
      expect(result, expectedUser);
    });

    test('currentSession deve retornar true se houver sessao ativa', () {
      // Arrange
      final expectedSession = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: User(
          id: '123',
          appMetadata: {},
          userMetadata: {},
          aud: 'aud',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      fakeGoTrueClient.mockSession = expectedSession;

      // Act
      final result = repository.currentSession;

      // Assert
      expect(result, expectedSession);
    });

    test('currentSession deve retornar false se nao houver sessao ativa', () {
      // Arrange
      fakeGoTrueClient.mockSession = null;

      // Act
      final result = repository.currentSession;

      // Assert
      expect(result, isNull);
    });
  });
}
