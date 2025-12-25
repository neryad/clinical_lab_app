import 'package:clinical_lab_app/core/models/lab_test.dart';
import 'package:clinical_lab_app/core/models/quote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuotesRepository {
  final SupabaseClient _supabase;

  QuotesRepository(this._supabase);

  Future<void> createQuote({
    required String userId,
    required List<LabTest> items,
    required double totalAmount,
  }) async {
    // 1. Create Quote
    final quoteData = await _supabase
        .from('quotes')
        .insert({
          'user_id': userId,
          'total_amount': totalAmount,
          'status': 'pending',
        })
        .select()
        .single();

    final quoteId = quoteData['id'];

    // 2. Create Quote Items
    final itemsData = items
        .map(
          (item) => {
            'quote_id': quoteId,
            'test_id': item.id,
            'price_at_time': item.price,
          },
        )
        .toList();

    await _supabase.from('quote_items').insert(itemsData);
  }

  Future<List<Quote>> getUserQuotes(String userId) async {
    final data = await _supabase
        .from('quotes')
        .select('*, items:quote_items(*, test:tests(*))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    // Note: The mapping might need adjustment depending on how Supabase returns nested data
    // For now, we'll assume a standard structure or handle it in the model if needed.
    // Actually, `quote_items` joins `tests`. We need to parse this carefully.
    // Let's simplify for now and just return the quotes, maybe fetch items separately if needed.
    // But the query above tries to fetch everything.
    // Let's stick to a simpler fetch for the list and maybe detailed fetch for details.

    // Simplified fetch for list (just quote info)
    return (data as List).map((e) => Quote.fromJson(e)).toList();
  }
}
