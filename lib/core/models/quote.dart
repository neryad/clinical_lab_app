import 'package:clinical_lab_app/core/models/lab_test.dart';

class Quote {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<LabTest>? items; // Optional, populated when fetching details

  Quote({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      items: json['items'] != null
          ? (json['items'] as List).map((i) {
              // Check if it's a direct LabTest or a nested quote_item
              if (i['test'] != null) {
                final testData = i['test'];
                // Use price_at_time if available, otherwise test price
                final price = i['price_at_time'] ?? testData['price'];

                // Create a copy of test data with the correct price
                final Map<String, dynamic> data = Map.from(testData);
                data['price'] = price;

                return LabTest.fromJson(data);
              }
              return LabTest.fromJson(i);
            }).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    };
  }
}
