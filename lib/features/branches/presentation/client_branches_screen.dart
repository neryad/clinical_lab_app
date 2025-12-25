import 'package:clinical_lab_app/core/models/branch.dart';
import 'package:clinical_lab_app/features/branches/data/branches_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final branchesListProvider = FutureProvider<List<Branch>>((ref) async {
  final repository = BranchesRepository(Supabase.instance.client);
  return repository.getBranches();
});

class ClientBranchesScreen extends ConsumerWidget {
  const ClientBranchesScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuestras Sucursales')),
      body: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return const Center(
              child: Text(
                'No hay sucursales disponibles por el momento.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          theme, Icons.location_on, branch.address),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          theme, Icons.phone, branch.phone ?? 'No disponible'),
                      const SizedBox(height: 12),
                      _buildInfoRow(theme, Icons.access_time,
                          branch.openingHours ?? 'No disponible'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (branch.phone != null)
                            TextButton.icon(
                              onPressed: () => _launchUrl('tel:${branch.phone}'),
                              icon: const Icon(Icons.call),
                              label: const Text('Llamar'),
                            ),
                          const SizedBox(width: 8),
                          if (branch.latitude != null &&
                              branch.longitude != null)
                            TextButton.icon(
                              onPressed: () => _launchUrl(
                                  'https://www.google.com/maps/search/?api=1&query=${branch.latitude},${branch.longitude}'),
                              icon: const Icon(Icons.map),
                              label: const Text('Ver en mapa'),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error al cargar sucursales: $err')),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}

