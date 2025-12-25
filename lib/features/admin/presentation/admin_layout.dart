import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

final _navigationRailExtendedProvider = StateProvider<bool>((ref) => true);

class AdminLayout extends ConsumerWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const breakpoint = 600;
        if (constraints.maxWidth >= breakpoint) {
          // Desktop layout
          final isExtended = ref.watch(_navigationRailExtendedProvider);

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(isExtended ? Icons.arrow_back : Icons.arrow_forward),
                onPressed: () {
                  ref.read(_navigationRailExtendedProvider.notifier).state =
                      !isExtended;
                },
              ),
              title: const Text('Admin Dashboard'),
            ),
            body: Row(
              children: [
                NavigationRail(
                  extended: isExtended,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.science),
                      label: Text('Pruebas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.store),
                      label: Text('Sucursales'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text('Usuarios'),
                    ),
                  ],
                  selectedIndex: _calculateSelectedIndex(context),
                  onDestinationSelected: (index) =>
                      _onItemTapped(index, context),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Salir'),
                          onPressed: () {
                            ref.read(authRepositoryProvider).signOut();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          // Mobile layout
          return Scaffold(
            appBar: AppBar(),
            drawer: Drawer(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () {
                      context.go('/admin/dashboard');
                      Navigator.pop(context);
                    },
                    selected: _calculateSelectedIndex(context) == 0,
                  ),
                  ListTile(
                    leading: const Icon(Icons.science),
                    title: const Text('Pruebas'),
                    onTap: () {
                      context.go('/admin/tests');
                      Navigator.pop(context);
                    },
                    selected: _calculateSelectedIndex(context) == 1,
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Sucursales'),
                    onTap: () {
                      context.go('/admin/branches');
                      Navigator.pop(context);
                    },
                    selected: _calculateSelectedIndex(context) == 2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Usuarios'),
                    onTap: () {
                      context.go('/admin/users');
                      Navigator.pop(context);
                    },
                    selected: _calculateSelectedIndex(context) == 3,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Salir'),
                    onTap: () {
                      ref.read(authRepositoryProvider).signOut();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            body: child,
          );
        }
      },
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/tests')) return 1;
    if (location.startsWith('/admin/branches')) return 2;
    if (location.startsWith('/admin/users')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/tests');
        break;
      case 2:
        context.go('/admin/branches');
        break;
      case 3:
        context.go('/admin/users');
        break;
    }
  }
}
