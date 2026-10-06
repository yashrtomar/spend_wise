import 'package:spend_wise/services/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_wise/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_wise/features/profile/domain/usecases/profile_usecases.dart';

// Data Sources
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(ref.watch(syncStoreProvider));
});

// Repositories
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final sync = ref.watch(syncServiceProvider.notifier);
  final local = ref.watch(profileLocalDataSourceProvider);
  return ProfileRepositoryImpl(local, sync);
});

// Use Cases
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});
