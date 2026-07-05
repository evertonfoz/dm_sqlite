import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  User? get currentUser;
  Session? get currentSession;
  Future<User?> signUp({
    required String email,
    required String password,
  });
  Future<User?> signIn({
    required String email,
    required String password,
  });
  Future signOut();
  Future resetPassword({
    required String email,
  });
}
