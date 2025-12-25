import 'package:clinical_lab_app/core/models/branch.dart';
import 'package:clinical_lab_app/features/branches/presentation/branches_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesListProvider);
    final searchQuery = ref.watch(_searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Sucursales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBranchDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  ref.read(_searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o dirección...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: branchesAsync.when(
              data: (branches) {
                final filteredBranches = branches.where((branch) {
                  final name = branch.name.toLowerCase();
                  final address = branch.address.toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) || address.contains(query);
                }).toList();

                if (filteredBranches.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron sucursales.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBranches.length,
                  itemBuilder: (context, index) {
                    return _BranchListItem(branch: filteredBranches[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchListItem extends ConsumerWidget {
  final Branch branch;

  const _BranchListItem({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const mobileBreakpoint = 600;
          const tabletBreakpoint = 900;

          if (constraints.maxWidth < mobileBreakpoint) {
            // Mobile layout
            return ExpansionTile(
              title: Text(branch.name),
              subtitle: Text(branch.address),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.phone,
                        text: branch.phone ?? 'No registrado',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.access_time,
                        text: branch.openingHours ?? 'No registrado',
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            onPressed: () =>
                                _showBranchDialog(context, ref, branch: branch),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteBranch(context, ref, branch.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (constraints.maxWidth < tabletBreakpoint) {
            // Tablet layout
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(branch.address, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoRow(
                        icon: Icons.phone,
                        text: branch.phone ?? 'No registrado',
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showBranchDialog(context, ref, branch: branch),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteBranch(context, ref, branch.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // Desktop layout
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(branch.name)),
                  Expanded(flex: 3, child: Text(branch.address)),
                  Expanded(flex: 2, child: Text(branch.phone ?? '-')),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showBranchDialog(context, ref, branch: branch),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteBranch(context, ref, branch.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

Future<void> _deleteBranch(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar'),
      content: const Text('¿Estás seguro de eliminar esta sucursal?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await ref.read(branchesRepositoryProvider).deleteBranch(id);
    ref.refresh(branchesListProvider);
  }
}

void _showBranchDialog(BuildContext context, WidgetRef ref, {Branch? branch}) {
  final nameCtrl = TextEditingController(text: branch?.name);
  final addressCtrl = TextEditingController(text: branch?.address);
  final phoneCtrl = TextEditingController(text: branch?.phone);
  final hoursCtrl = TextEditingController(text: branch?.openingHours);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(branch == null ? 'Nueva Sucursal' : 'Editar Sucursal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hoursCtrl,
              decoration: const InputDecoration(
                labelText: 'Horario',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final newBranch = Branch(
              id: branch?.id ?? '',
              name: nameCtrl.text,
              address: addressCtrl.text,
              phone: phoneCtrl.text,
              openingHours: hoursCtrl.text,
            );

            if (branch == null) {
              await ref
                  .read(branchesRepositoryProvider)
                  .createBranch(newBranch);
            } else {
              await ref
                  .read(branchesRepositoryProvider)
                  .updateBranch(newBranch);
            }

            if (context.mounted) Navigator.pop(ctx);
            ref.refresh(branchesListProvider);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
