import 'package:spend_wise/features/profile/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _supabase;

  ProfileRemoteDataSource({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<UserProfileModel?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .schema('spendwise')
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = profile.toJson();
    data.remove('created_at');
    data['updated_at'] = DateTime.now().toIso8601String();

    await _supabase
        .schema('spendwise')
        .from('user_profiles')
        .upsert(data);
  }
}
