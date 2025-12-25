import 'package:clinical_lab_app/core/models/branch.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:clinical_lab_app/features/branches/data/branches_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final branchesRepositoryProvider = Provider<BranchesRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BranchesRepository(supabase);
});

final branchesListProvider = FutureProvider.autoDispose<List<Branch>>((
  ref,
) async {
  final repository = ref.watch(branchesRepositoryProvider);
  return repository.getBranches();
});
