import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';

class CircularAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? userId;

  const CircularAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final effectiveUserId = userId ?? user?.id;

    return FutureBuilder<String?>(
      future: _getImage(effectiveUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            child: SizedBox(
              height: radius * 0.8,
              width: radius * 0.8,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final resolvedImage = snapshot.data;

        if (resolvedImage == null || resolvedImage.trim().isEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: radius, color: Colors.grey[600]),
          );
        }

        try {
          if (resolvedImage.startsWith('data:image')) {
            // Base64 image
            final base64String = resolvedImage.split(',').last;
            final imageBytes = base64Decode(base64String);
            return CircleAvatar(
              radius: radius,
              backgroundImage: MemoryImage(imageBytes),
              backgroundColor: Colors.grey[300],
            );
          } else {
            // Network image
            return CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(resolvedImage),
              backgroundColor: Colors.grey[300],
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error loading image: $e');
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.error, size: radius, color: Colors.red),
          );
        }
      },
    );
  }

  Future<String?> _getImage(String? effectiveUserId) async {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) return imageUrl;
    if (effectiveUserId == null) return null;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_${effectiveUserId}_image');
  }
}
