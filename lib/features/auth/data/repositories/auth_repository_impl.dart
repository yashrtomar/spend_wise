import 'package:spend_wise/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spend_wise/features/auth/data/models/app_user_model.dart';
import 'package:spend_wise/features/auth/domain/entities/app_user.dart';
import 'package:spend_wise/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  AppUser? get currentUser {
    final user = _remoteDataSource.currentUser;
    if (user == null) return null;
    return AppUserModel.fromSupabaseUser(user);
  }

  @override
  Stream<AppUser?> get authState {
    return _remoteDataSource.authState.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return AppUserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _remoteDataSource.register(name: name, email: email, password: password);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _remoteDataSource.resetPassword(email);
  }
}
