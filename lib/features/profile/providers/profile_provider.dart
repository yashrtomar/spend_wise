import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/models/user_profile.dart';
import 'package:spend_wise/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  late final ProfileService _profileService;

  @override
  FutureOr<UserProfile?> build() async {
    _profileService = ref.watch(profileServiceProvider);
    return _profileService.getProfile();
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
      await _profileService.updateProfile(updatedProfile);
    } catch (e) {
      // Revert on failure
      state = AsyncData(currentProfile);
      rethrow;
    }
  }
}
