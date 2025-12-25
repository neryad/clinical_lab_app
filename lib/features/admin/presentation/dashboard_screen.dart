import 'package:clinical_lab_app/features/admin/presentation/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: statsAsync.when(
        data: (stats) {
          final statCards = [
            _StatCard(
              title: 'Pruebas',
              count: stats['tests'] ?? 0,
              icon: Icons.science,
              color: Colors.blue,
              onTap: () => context.go('/admin/tests'),
            ),
            _StatCard(
              title: 'Sucursales',
              count: stats['branches'] ?? 0,
              icon: Icons.store,
              color: Colors.green,
              onTap: () => context.go('/admin/branches'),
            ),
            _StatCard(
              title: 'Usuarios',
              count: stats['users'] ?? 0,
              icon: Icons.people,
              color: Colors.orange,
              onTap: () => context.go('/admin/users'),
            ),
          ];

          return LayoutBuilder(builder: (context, constraints) {
            const breakpoint = 600;
            if (constraints.maxWidth >= breakpoint) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen General',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: statCards,
                    ),
                  ],
                ),
              );
            } else {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: statCards.length,
                itemBuilder: (context, index) => statCards[index],
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
              );
            }
          });
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              FittedBox(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
