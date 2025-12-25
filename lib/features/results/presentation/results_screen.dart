import 'package:clinical_lab_app/core/models/test_result.dart';
import 'package:clinical_lab_app/features/auth/presentation/auth_providers.dart';
import 'package:clinical_lab_app/features/results/data/results_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ResultsRepository(supabase);
});

final resultsListProvider = FutureProvider<List<TestResult>>((ref) async {
  final userProfile = await ref.watch(currentUserProvider.future);
  if (userProfile == null) return [];

  final repository = ref.watch(resultsRepositoryProvider);
  return repository.getResults(userProfile.id);
});

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle error
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Resultados')),
      body: resultsAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(
              child: Text(
                'No tienes resultados disponibles.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final isReady = result.status == 'ready';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isReady
                        ? Colors.green[100]
                        : Colors.orange[100],
                    child: Icon(
                      isReady ? Icons.check : Icons.hourglass_empty,
                      color: isReady ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    result.testName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(result.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isReady ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isReady ? Colors.green : Colors.orange,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isReady ? 'Listo' : 'Pendiente',
                          style: TextStyle(
                            color: isReady ? Colors.green : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: isReady && result.fileUrl != null
                      ? IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          onPressed: () => _openPdf(result.fileUrl!),
                          tooltip: 'Ver PDF',
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error al cargar resultados: $err')),
      ),
    );
  }
}
