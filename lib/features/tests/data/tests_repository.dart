import 'package:clinical_lab_app/core/models/lab_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestsRepository {
  final SupabaseClient _supabase;

  TestsRepository(this._supabase);

  Future<List<LabTest>> getTests() async {
    final data = await _supabase
        .from('tests')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => LabTest.fromJson(e)).toList();
  }

  Future<void> createTest(LabTest test) async {
    // We exclude 'id' to let Supabase generate it, but our model requires it.
    // In a real app, we might use a DTO for creation without ID.
    // Here we just pass the map excluding ID if it's empty/placeholder.
    final map = test.toJson();
    map.remove('id'); // Let DB generate ID

    await _supabase.from('tests').insert(map);
  }

  Future<void> updateTest(LabTest test) async {
    final map = test.toJson();
    map.remove('id'); // Don't update ID

    await _supabase.from('tests').update(map).eq('id', test.id);
  }

  Future<void> deleteTest(String id) async {
    await _supabase.from('tests').delete().eq('id', id);
  }
}
