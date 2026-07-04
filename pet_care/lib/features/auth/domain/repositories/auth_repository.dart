import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Future<void> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  User? getCurrentUser();
  Future<bool> checkSession();
}
