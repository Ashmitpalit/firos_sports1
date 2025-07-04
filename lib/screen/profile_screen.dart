import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/circular_avatar.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularAvatar(imageUrl: user?.imageUrl, radius: 50, userId: user?.id),
            const SizedBox(height: 16),
            Text('Name: ${user?.name ?? "N/A"}'),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? "N/A"}'),
            const SizedBox(height: 8),
            Text('Age: ${user?.age?.toString() ?? "N/A"}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Verified '),
                Text(
                  '✅️',
                  style: TextStyle(
                    color: const Color(0xFF1DA1F2), // Twitter/X blue
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Logout',
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).clearUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
