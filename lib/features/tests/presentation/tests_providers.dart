import 'package:clinical_lab_app/core/models/lab_test.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:clinical_lab_app/features/tests/data/tests_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final testsRepositoryProvider = Provider<TestsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TestsRepository(supabase);
});

final testsListProvider = FutureProvider.autoDispose<List<LabTest>>((
  ref,
) async {
  final repository = ref.watch(testsRepositoryProvider);
  return repository.getTests();
});
