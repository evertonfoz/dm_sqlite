import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_care/features/auth/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository { 
  final SupabaseClient _client;
  SupabaseAuthRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  @override 
  User? get currentUser => _client.auth.currentUser;

  @override 
  Session? get currentSession => _client.auth.currentSession;

  @override 
  Future<User?> signUp({ 
    required String email, 
    required String password, 
  }) async { 
    final response = await _client.auth.signUp( 
      email: email, 
      password: password, 
    );
    return response.user; 
  }

  @override 
  Future<User?> signIn({ 
    required String email,
    required String password, 
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override 
  Future signOut() { 
    return _client.auth.signOut(); 
  }

  @override 
  Future resetPassword({ 
    required String email, 
  }) { 
    return _client.auth.resetPasswordForEmail(email); 
  } 
}
