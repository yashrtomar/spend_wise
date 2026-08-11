import 'package:spend_wise/features/auth/domain/entities/app_user.dart';
import 'package:spend_wise/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<void> execute({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> execute({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.register(name: name, email: email, password: password);
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> execute() {
    return _repository.logout();
  }
}

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> execute(String email) {
    return _repository.resetPassword(email);
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  AppUser? execute() {
    return _repository.currentUser;
  }
}

class GetAuthStateUseCase {
  final AuthRepository _repository;

  GetAuthStateUseCase(this._repository);

  Stream<AppUser?> execute() {
    return _repository.authState;
  }
}
