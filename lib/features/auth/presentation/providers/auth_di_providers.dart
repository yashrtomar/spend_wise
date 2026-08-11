import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spend_wise/features/auth/domain/entities/app_user.dart';
import 'package:spend_wise/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:spend_wise/features/auth/domain/repositories/auth_repository.dart';
import 'package:spend_wise/features/auth/domain/usecases/auth_usecases.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  return GetAuthStateUseCase(ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final getAuthStateUseCase = ref.watch(getAuthStateUseCaseProvider);
  return getAuthStateUseCase.execute();
});
