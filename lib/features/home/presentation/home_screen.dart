import 'package:clinical_lab_app/core/theme/app_theme.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      {
        'icon': Icons.location_on,
        'label': 'Sucursales',
        'path': '/branches',
      },
      {
        'icon': Icons.description,
        'label': 'Resultados',
        'path': '/results',
      },
      {
        'icon': Icons.science,
        'label': 'Pruebas',
      },
      {
        'icon': Icons.calculate,
        'label': 'Cotizar',
        'path': '/quotes',
      },
      {
        'icon': Icons.person,
        'label': 'Perfil',
        'path': '/profile',
      },
      {
        'icon': Icons.receipt,
        'label': 'Facturar',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio Clínico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '¿En qué te podemos ayudar?',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(menuItems.length, (index) {
                  final item = menuItems[index];
                  return _buildMenuOption(
                    context: context,
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    color: AppTheme.menuOptionColors[index],
                    onTap: item.containsKey('path')
                        ? () => context.push(item['path'] as String)
                        : null,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

