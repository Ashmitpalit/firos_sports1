import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/api_response.dart';

class ApiService {
  static const String _apiUrl = 'https://mock-api.example.com/face-match';

  Future<ApiResponse> matchFaces(String aadhaarImage, String liveImage) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse(status: 'match', age: 30);
      /*
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aadhaar_image': aadhaarImage,
          'live_image': liveImage,
        }),
      );
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
      */
    } catch (e) {
      throw Exception('Face matching failed: $e');
    }
  }
}
