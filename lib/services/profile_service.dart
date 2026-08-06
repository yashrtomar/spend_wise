import 'package:spend_wise/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<UserProfile?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .schema('spendwise')
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  Future<void> updateProfile(UserProfile profile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = profile.toJson();
    // Do not try to update created_at, the DB handles that.
    data.remove('created_at');
    
    // update updated_at just in case
    data['updated_at'] = DateTime.now().toIso8601String();

    await _supabase
        .schema('spendwise')
        .from('user_profiles')
        .upsert(data);
  }
}