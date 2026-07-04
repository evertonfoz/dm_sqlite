import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _supabaseClient;

  SupabaseAuthRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro ao cadastrar usuário: $e');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao sair da conta: $e');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Erro ao recuperar senha: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  @override
  Future<bool> checkSession() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
}
