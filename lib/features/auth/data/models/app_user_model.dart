import 'package:spend_wise/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    super.email,
    super.name,
  });

  factory AppUserModel.fromSupabaseUser(supabase.User user) {
    return AppUserModel(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['name'] as String?,
    );
  }
}
