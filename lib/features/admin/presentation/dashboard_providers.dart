import 'package:clinical_lab_app/features/admin/data/dashboard_repository.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return DashboardRepository(supabase);
});

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardStats();
});
