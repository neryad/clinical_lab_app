import 'dart:typed_data';
import 'package:clinical_lab_app/core/models/lab_test.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<Uint8List> generateQuote(
    List<LabTest> items, {
    DateTime? date,
  }) async {
    final pdf = pw.Document();
    final total = items.fold(0.0, (sum, item) => sum + item.price);
    final displayDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(date ?? DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Laboratorio Clínico',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Cotización',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Fecha: $displayDate'),
              pw.SizedBox(height: 40),

              // Table
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Prueba', 'Categoría', 'Precio'],
                data: items
                    .map(
                      (item) => [
                        item.name,
                        item.category ?? 'General',
                        '\$${item.price.toStringAsFixed(2)}',
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Estimado: ',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              // Footer
              pw.Divider(),
              pw.Text(
                'Este documento es una cotización preliminar y no representa una factura final. Los precios están sujetos a cambios.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
