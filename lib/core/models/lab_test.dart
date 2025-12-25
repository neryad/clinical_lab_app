class LabTest {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? requirements;
  final String? category;

  LabTest({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.requirements,
    this.category,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      requirements: json['requirements'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'requirements': requirements,
      'category': category,
    };
  }
}
