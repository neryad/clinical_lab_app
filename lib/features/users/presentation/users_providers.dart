import 'package:clinical_lab_app/core/models/user_profile.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:clinical_lab_app/features/users/data/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UsersRepository(supabase);
});

final usersListProvider = FutureProvider.autoDispose<List<UserProfile>>((
  ref,
) async {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getUsers();
});
