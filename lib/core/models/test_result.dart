class TestResult {
  final String id;
  final String userId;
  final String testName;
  final DateTime date;
  final String status; // 'pending', 'ready'
  final String? fileUrl;

  TestResult({
    required this.id,
    required this.userId,
    required this.testName,
    required this.date,
    required this.status,
    this.fileUrl,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      userId: json['user_id'],
      testName: json['test_name'],
      date: DateTime.parse(json['created_at']),
      status: json['status'],
      fileUrl: json['file_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'test_name': testName,
      'created_at': date.toIso8601String(),
      'status': status,
      'file_url': fileUrl,
    };
  }
}
