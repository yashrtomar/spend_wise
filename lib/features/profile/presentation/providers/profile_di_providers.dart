import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_wise/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_wise/features/profile/domain/usecases/profile_usecases.dart';

// Data Sources
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource();
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource();
});

// Repositories
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDataSourceProvider);
  final local = ref.watch(profileLocalDataSourceProvider);
  return ProfileRepositoryImpl(remote, local);
});

// Use Cases
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});
