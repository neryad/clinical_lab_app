import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  final SupabaseClient _supabase;

  DashboardRepository(this._supabase);

  Future<Map<String, int>> getDashboardStats() async {
    final testsCount = await _supabase.from('tests').count();
    final branchesCount = await _supabase.from('branches').count();
    final usersCount = await _supabase.from('profiles').count();

    return {
      'tests': testsCount,
      'branches': branchesCount,
      'users': usersCount,
    };
  }
}
