import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String dbUrl = "https://sportsone-6c433-default-rtdb.firebaseio.com/";

  Future<bool> signup(String email, String password) async {
    final url = Uri.parse("$dbUrl/users.json");
    final response = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode == 200;
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$dbUrl/users.json");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      for (final entry in data.entries) {
        if (entry.value['email'] == email && entry.value['password'] == password) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("loggedIn", true);
          return true;
        }
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("loggedIn") ?? false;
  }
}
