import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<UserModel?> login(String email, String password) async {
    try {
      final snapshot = await _db.child('users').get().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Database fetch timed out'),
          );
      if (snapshot.exists) {
        final users = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in users.entries) {
          final userData = Map<String, dynamic>.from(entry.value as Map);
          if (userData['email'] == email &&
              userData['password'] == _hashPassword(password)) {
            final user = UserModel.fromJson(entry.key as String, userData);
            // Store imageUrl in SharedPreferences for local access
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_${user.id}_image', user.imageUrl ?? '');
            return user;
          }
        }
      }
      throw Exception('Invalid email or password');
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<void> registerUser(UserModel user, File? image) async {
    try {
      if (kDebugMode) {
        print('Starting user registration: ${user.email}');
      }

      String? imageUrl;
      if (image != null) {
        if (!await image.exists()) {
          throw Exception('Image file does not exist: ${image.path}');
        }
        if (kDebugMode) {
          print('Converting image to base64: ${image.path}');
        }
        // Convert image to base64
        final bytes = await image.readAsBytes();
        imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final userData = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: _hashPassword(user.password),
        age: user.age,
        imageUrl: imageUrl,
      ).toJson();

      if (kDebugMode) {
        print('Saving user data to Realtime Database: $userData');
      }

      // Save user data to Firebase Realtime Database
      await _db.child('users/${user.id}').set(userData).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Database write timed out'),
          );

      // Save image to SharedPreferences
      if (imageUrl != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_${user.id}_image', imageUrl);
        if (kDebugMode) {
          print('Image saved to SharedPreferences for user: ${user.id}');
        }
      }

      if (kDebugMode) {
        print('User registration successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      throw Exception('Registration failed: $e');
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
