import 'package:clinical_lab_app/core/models/branch.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BranchesRepository {
  final SupabaseClient _supabase;

  BranchesRepository(this._supabase);

  Future<List<Branch>> getBranches() async {
    final data = await _supabase
        .from('branches')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => Branch.fromJson(e)).toList();
  }

  Future<void> createBranch(Branch branch) async {
    final map = branch.toJson();
    map.remove('id'); // Let DB generate ID

    await _supabase.from('branches').insert(map);
  }

  Future<void> updateBranch(Branch branch) async {
    final map = branch.toJson();
    map.remove('id'); // Don't update ID

    await _supabase.from('branches').update(map).eq('id', branch.id);
  }

  Future<void> deleteBranch(String id) async {
    await _supabase.from('branches').delete().eq('id', id);
  }
}
