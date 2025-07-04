import 'package:flutter/material.dart';

class CircularAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? userId;
  final double radius;

  const CircularAvatar({
    super.key,
    required this.imageUrl,
    required this.userId,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Optionally navigate to user profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: userId ?? ''),
          ),
        );
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
            ? NetworkImage(imageUrl!)
            : null,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
    );
  }
}

// Dummy ProfileScreen for now — replace with actual implementation
class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(child: Text("Profile of $userId")),
    );
  }
}
