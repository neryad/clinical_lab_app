import 'package:clinical_lab_app/core/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersRepository {
  final SupabaseClient _supabase;

  UsersRepository(this._supabase);

  Future<List<UserProfile>> getUsers() async {
    final data = await _supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => UserProfile.fromJson(e)).toList();
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _supabase.from('profiles').update({'role': newRole}).eq('id', userId);
  }
}
