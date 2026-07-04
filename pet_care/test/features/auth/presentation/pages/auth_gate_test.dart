import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/presentation/pages/auth_gate.dart';
import 'package:pet_care/features/auth/presentation/pages/onboarding_page.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_list_page.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';

class FakeGoTrueClient extends Fake implements GoTrueClient {
  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();
  Session? mockSession;

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;

  @override
  Session? get currentSession => mockSession;

  void emit(AuthState state) {
    mockSession = state.session;
    _controller.add(state);
  }

  void dispose() {
    _controller.close();
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final FakeGoTrueClient _auth;

  FakeSupabaseClient(this._auth);

  @override
  FakeGoTrueClient get auth => _auth;
}

class MockTutorController extends ChangeNotifier implements TutorController {
  @override
  List<Tutor> get tutors => [];

  @override
  bool get isLoading => false;

  @override
  bool get isSyncing => false;

  @override
  bool get isPaginating => false;

  @override
  bool get isInserting => false;

  @override
  bool get isUpdating => false;

  @override
  bool get isDeleting => false;

  @override
  String? get errorMessage => null;

  @override
  bool get hasMoreData => false;

  @override
  Future<void> loadFirstPage() async {}

  @override
  Future<void> syncData() async {}

  @override
  Future<void> getAllTutors() async {}

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<void> insertTutor(Tutor tutor) async {}

  @override
  Future<void> updateTutor(Tutor tutor) async {}

  @override
  Future<void> deleteTutor(int id) async {}

  @override
  Future<Tutor?> getTutorById(int id) async => null;

  @override
  Future<bool> hasActivePets(int tutorId) async => false;

  @override
  Future<void> addFakeTutors() async {}
}

void main() {
  late FakeGoTrueClient fakeGoTrueClient;
  late FakeSupabaseClient fakeSupabaseClient;
  late MockTutorController mockTutorController;

  setUp(() {
    fakeGoTrueClient = FakeGoTrueClient();
    fakeSupabaseClient = FakeSupabaseClient(fakeGoTrueClient);
    mockTutorController = MockTutorController();
  });

  tearDown(() {
    fakeGoTrueClient.dispose();
    mockTutorController.dispose();
  });

  testWidgets('AuthGate mostra indicador de carregamento quando conexao esta em espera', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          supabaseClient: fakeSupabaseClient,
          tutorController: mockTutorController,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AuthGate redireciona para TutorListPage quando sessao esta ativa', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          supabaseClient: fakeSupabaseClient,
          tutorController: mockTutorController,
        ),
      ),
    );

    // Emite estado com sessao ativa
    fakeGoTrueClient.emit(AuthState(
      AuthChangeEvent.signedIn,
      Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: User(
          id: '123',
          appMetadata: {},
          userMetadata: {},
          aud: 'aud',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(TutorListPage), findsOneWidget);
  });

  testWidgets('AuthGate redireciona para OnboardingPage quando nao ha sessao ativa', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          supabaseClient: fakeSupabaseClient,
          tutorController: mockTutorController,
        ),
      ),
    );

    // Emite estado sem sessao ativa
    fakeGoTrueClient.emit(AuthState(
      AuthChangeEvent.signedOut,
      null,
    ));

    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}
