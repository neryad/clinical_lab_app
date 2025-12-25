import 'package:clinical_lab_app/core/models/quote.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:clinical_lab_app/features/quotes/presentation/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:clinical_lab_app/features/quotes/presentation/cart_screen.dart'; // For quotesRepositoryProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final userQuotesProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return [];
  final repository = ref.watch(quotesRepositoryProvider);
  return repository.getUserQuotes(user.id);
});

class UserQuotesScreen extends ConsumerWidget {
  const UserQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(userQuotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Cotizaciones')),
      body: quotesAsync.when(
        data: (quotes) {
          if (quotes.isEmpty) {
            return const Center(
              child: Text('No tienes cotizaciones registradas.'),
            );
          }
          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text('Cotización #${quote.id.substring(0, 8)}'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(quote.createdAt),
                  ),
                  trailing: Text(
                    '\$${quote.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  children: [
                    // We need to fetch items or if they are included display them
                    // The repository said it might return items.
                    // Let's assume for now we just show the status.
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Estado: '),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(quote.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              quote.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _generatePdf(context, quote),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Ver PDF'),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  Future<void> _generatePdf(BuildContext context, Quote quote) async {
    if (quote.items == null || quote.items!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay detalles disponibles para esta cotización.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final pdfBytes = await PdfGenerator.generateQuote(
        quote.items!,
        date: quote.createdAt,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Cotizacion_${quote.id.substring(0, 8)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
