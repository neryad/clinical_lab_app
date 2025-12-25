import 'package:clinical_lab_app/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepository(supabase);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final currentUserProvider = FutureProvider((ref) async {
  final authState = ref.watch(authStateProvider);

  // Reload profile when auth state changes (login/logout)
  if (authState.asData?.value.event == AuthChangeEvent.signedIn ||
      authState.asData?.value.event == AuthChangeEvent.initialSession) {
    return ref.watch(authRepositoryProvider).getUserProfile();
  }

  return null;
});
