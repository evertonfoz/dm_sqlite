import 'package:flutter/foundation.dart';
import 'package:pet_care/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  AuthController({AuthRepository? repository})
      : _repository = repository ?? SupabaseAuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void loadCurrentUser() {
    _currentUser = _repository.currentUser;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    if (_isLoading) { return false; }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _repository.signUp(
        email: email.trim(),
        password: password,
      );
      _currentUser = user;
      return user != null;
    } catch (error) {
      debugPrint('Erro ao criar usuário: $error');
      _errorMessage = 'Não foi possível criar a conta. ' +
          'Verifique os dados e tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (_isLoading) { return false; }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      _currentUser = user;
      return user != null;
    } catch (error) {
      debugPrint('Erro ao fazer login: $error');
      _errorMessage = 'Não foi possível entrar. ' +
          'Confira seu e-mail e senha.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_isLoading) { return; }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signOut();
      _currentUser = null;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('hasSeenOnboarding');
      } catch (e) {
        debugPrint('Erro ao resetar onboarding no logout: $e');
      }
    } catch (error) {
      debugPrint('Erro ao sair da conta: $error');
      _errorMessage = 'Não foi possível sair da conta. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
  }) async {
    if (_isLoading) { return false; }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.resetPassword(
        email: email.trim(),
      );
      return true;
    } catch (error) {
      debugPrint('Erro ao recuperar senha: $error');
      _errorMessage = 'Não foi possível enviar a recuperação ' +
          'de senha. Verifique o e-mail informado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
