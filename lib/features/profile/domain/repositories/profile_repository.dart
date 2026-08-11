import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();
  
  Future<void> updateProfile(UserProfile profile);
}
