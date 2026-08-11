import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';
import 'package:spend_wise/features/profile/presentation/providers/profile_di_providers.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  FutureOr<UserProfile?> build() async {
    final getProfileUseCase = ref.watch(getProfileUseCaseProvider);
    return getProfileUseCase.execute();
  }

  Future<void> updateBudget(double newBudget) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      monthlyBudget: newBudget,
      updatedAt: DateTime.now(),
    );

    // Optimistic UI update
    state = AsyncData(updatedProfile);

    try {
      final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
      await updateProfileUseCase.execute(updatedProfile);
    } catch (e) {
      // Revert on failure
      state = AsyncData(currentProfile);
      rethrow;
    }
  }
}
