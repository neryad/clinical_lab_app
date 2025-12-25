import 'package:clinical_lab_app/core/models/lab_test.dart';
import 'package:clinical_lab_app/features/tests/presentation/tests_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class TestsScreen extends ConsumerWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsListProvider);
    final searchQuery = ref.watch(_searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pruebas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTestDialog(context, ref),
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
                hintText: 'Buscar por nombre o categoría...',
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
            child: testsAsync.when(
              data: (tests) {
                final filteredTests = tests.where((test) {
                  final name = test.name.toLowerCase();
                  final category = test.category?.toLowerCase() ?? '';
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) || category.contains(query);
                }).toList();

                if (filteredTests.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron pruebas.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTests.length,
                  itemBuilder: (context, index) {
                    return _TestListItem(test: filteredTests[index]);
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

class _TestListItem extends ConsumerWidget {
  final LabTest test;

  const _TestListItem({required this.test});

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
              title: Text(test.name),
              subtitle: Text(test.category ?? '-'),
              trailing: Text('\$${test.price.toStringAsFixed(2)}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test.description ?? 'Sin descripción.'),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            onPressed: () =>
                                _showTestDialog(context, ref, test: test),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () => _deleteTest(context, ref, test.id),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          test.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${test.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Text(test.category ?? '-', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          test.description ?? 'Sin descripción.',
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showTestDialog(context, ref, test: test),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTest(context, ref, test.id),
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
                  Expanded(flex: 3, child: Text(test.name)),
                  Expanded(flex: 2, child: Text(test.category ?? '-')),
                  Expanded(
                    flex: 1,
                    child: Text('\$${test.price.toStringAsFixed(2)}'),
                  ),
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
                                _showTestDialog(context, ref, test: test),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTest(context, ref, test.id),
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

Future<void> _deleteTest(BuildContext context, WidgetRef ref, String id) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar'),
      content: const Text('¿Estás seguro de eliminar esta prueba?'),
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
    await ref.read(testsRepositoryProvider).deleteTest(id);
    ref.refresh(testsListProvider);
  }
}

void _showTestDialog(BuildContext context, WidgetRef ref, {LabTest? test}) {
  final nameCtrl = TextEditingController(text: test?.name);
  final categoryCtrl = TextEditingController(text: test?.category);
  final priceCtrl = TextEditingController(text: test?.price.toString());
  final descCtrl = TextEditingController(text: test?.description);
  final reqCtrl = TextEditingController(text: test?.requirements);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(test == null ? 'Nueva Prueba' : 'Editar Prueba'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.science_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reqCtrl,
              decoration: const InputDecoration(
                labelText: 'Requisitos',
                prefixIcon: Icon(Icons.playlist_add_check),
              ),
              maxLines: 2,
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
            final price = double.tryParse(priceCtrl.text) ?? 0.0;
            final newTest = LabTest(
              id: test?.id ?? '', // ID ignored on create
              name: nameCtrl.text,
              category: categoryCtrl.text,
              price: price,
              description: descCtrl.text,
              requirements: reqCtrl.text,
            );

            if (test == null) {
              await ref.read(testsRepositoryProvider).createTest(newTest);
            } else {
              await ref.read(testsRepositoryProvider).updateTest(newTest);
            }

            if (context.mounted) Navigator.pop(ctx);
            ref.refresh(testsListProvider);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
