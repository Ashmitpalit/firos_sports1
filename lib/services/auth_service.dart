// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  Future<UserModel?> login(String email, String password) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}users.json');
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
        final Map<String, dynamic> users = jsonDecode(response.body);
        for (var entry in users.entries) {
          final userData = entry.value;
          if (userData['email'] == email && userData['password'] == password) {
            return UserModel(
              id: entry.key,
              name: userData['name'],
              email: userData['email'],
            );
          }
        }
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final url = Uri.parse('${Constants.baseUrl}users/$userId.json');
      final response = await http.patch(
        url,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return UserModel(
          id: userId,
          name: name,
          email: email,
        );
      } else {
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}users/$userId.json');
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
        final userData = jsonDecode(response.body);
        return UserModel(
          id: userId,
          name: userData['name'],
          email: userData['email'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }
}