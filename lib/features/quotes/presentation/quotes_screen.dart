import 'package:clinical_lab_app/features/quotes/presentation/cart_provider.dart';
import 'package:clinical_lab_app/features/tests/presentation/tests_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsListProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizar Pruebas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/quotes/history'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push('/cart'),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: testsAsync.when(
        data: (tests) {
          if (tests.isEmpty) {
            return const Center(child: Text('No hay pruebas disponibles.'));
          }
          return ListView.builder(
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final isInCart = cart.any((item) => item.id == test.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(test.name),
                  subtitle: Text(
                    '${test.category ?? 'General'} - \$${test.price.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isInCart ? Icons.check_circle : Icons.add_circle_outline,
                      color: isInCart ? Colors.green : null,
                    ),
                    onPressed: () {
                      if (isInCart) {
                        ref.read(cartProvider.notifier).removeTest(test.id);
                      } else {
                        ref.read(cartProvider.notifier).addTest(test);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
