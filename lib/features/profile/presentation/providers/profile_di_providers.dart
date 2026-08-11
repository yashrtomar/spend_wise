import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_wise/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_wise/features/profile/domain/usecases/profile_usecases.dart';

// Data Sources
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource();
});

// Repositories
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});

// Use Cases
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});
