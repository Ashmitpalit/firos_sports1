import 'package:flutter/material.dart';
import '../widgets/circular_avatar.dart';

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
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularAvatar(imageUrl: imageUrl, radius: 50),
          const SizedBox(height: 16),
          Text('Name: $name'),
          const SizedBox(height: 8),
          Text('Email: $email'),
          const SizedBox(height: 8),
          Text('Age: $age'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Verified '),
              Text(
                '✅️',
                style: TextStyle(
                  color: Color(0xFF1DA1F2),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
