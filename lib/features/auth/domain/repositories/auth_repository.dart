import 'package:spend_wise/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});
  
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });
  
  Future<void> logout();
  
  Future<void> resetPassword(String email);
  
  AppUser? get currentUser;
  
  Stream<AppUser?> get authState;
}
