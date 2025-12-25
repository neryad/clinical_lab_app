import 'package:clinical_lab_app/features/admin/presentation/admin_layout.dart';
import 'package:clinical_lab_app/features/admin/presentation/dashboard_screen.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:clinical_lab_app/features/auth/presentation/login_screen.dart';
import 'package:clinical_lab_app/features/auth/presentation/register_screen.dart';
import 'package:clinical_lab_app/features/branches/presentation/branches_screen.dart';
import 'package:clinical_lab_app/features/branches/presentation/client_branches_screen.dart';
import 'package:clinical_lab_app/features/home/presentation/home_screen.dart';
import 'package:clinical_lab_app/features/profile/presentation/profile_screen.dart';
import 'package:clinical_lab_app/features/quotes/presentation/cart_screen.dart';
import 'package:clinical_lab_app/features/quotes/presentation/quotes_screen.dart';
import 'package:clinical_lab_app/features/quotes/presentation/user_quotes_screen.dart';
import 'package:clinical_lab_app/features/results/presentation/results_screen.dart';
import 'package:clinical_lab_app/features/tests/presentation/tests_screen.dart';
import 'package:clinical_lab_app/features/users/presentation/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  // Note: In a real app we'd wait for the user profile to load to check roles.
  // For now, we'll do a simple check or rely on the UI to hide admin features.
  // final currentUser = ref.watch(currentUserProvider).asData?.value;

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value.session != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';
      final userProfile = ref.watch(currentUserProvider).asData?.value;
      final isAdminRoute = state.uri.toString().startsWith('/admin');

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        if (userProfile?.role == 'admin') {
          return '/admin/dashboard';
        }
        return '/';
      }

      if (isLoggedIn &&
          state.uri.toString() == '/' &&
          userProfile?.role == 'admin') {
        return '/admin/dashboard';
      }

      if (isAdminRoute && userProfile?.role != 'admin') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/quotes',
        builder: (context, state) => const QuotesScreen(),
        routes: [
          GoRoute(
            path: 'history',
            builder: (context, state) => const UserQuotesScreen(),
          ),
        ],
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/branches',
        builder: (context, state) => const ClientBranchesScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsScreen(),
      ),
      // Admin Shell
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/tests',
            builder: (context, state) => const TestsScreen(),
          ),
          GoRoute(
            path: '/admin/branches',
            builder: (context, state) => const BranchesScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UsersScreen(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
