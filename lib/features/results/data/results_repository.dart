import 'package:clinical_lab_app/core/models/test_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultsRepository {
  final SupabaseClient _supabase;

  ResultsRepository(this._supabase);

  Future<List<TestResult>> getResults(String userId) async {
    final data = await _supabase
        .from('test_results')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => TestResult.fromJson(e)).toList();
  }
}
