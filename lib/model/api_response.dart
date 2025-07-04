class ApiResponse {
  final String status;
  final int? age;
  final String? alert;

  ApiResponse({required this.status, this.age, this.alert});

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        status: json['status'] as String,
        age: json['age'] as int?,
        alert: json['alert'] as String?,
      );
}
