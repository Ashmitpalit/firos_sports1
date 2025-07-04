import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileScreenLite extends StatelessWidget {
  final String name;
  final String email;
  final String age;
  final String? imageUrl;

  const ProfileScreenLite({
    super.key,
    required this.name,
    required this.email,
    required this.age,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (imageUrl == null || imageUrl!.isEmpty) {
      avatar = const CircleAvatar(
        radius: 40,
        child: Icon(Icons.person, size: 40),
      );
    } else if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        final imageBytes = base64Decode(base64String);
        avatar = CircleAvatar(
          radius: 40,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        avatar = const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 40),
        );
      }
    } else {
      avatar = CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return AlertDialog(
      title: const Text('User Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email),
          const SizedBox(height: 4),
          Text('Age: $age'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
