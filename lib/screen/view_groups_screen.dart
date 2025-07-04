import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../widgets/circular_avatar.dart';
import '../providers/user_provider.dart';
import 'chat_screen.dart';
import 'profile_screen1.dart';

class ViewGroupsScreen extends StatefulWidget {
  const ViewGroupsScreen({super.key});

  @override
  State<ViewGroupsScreen> createState() => _ViewGroupsScreenState();
}

class _ViewGroupsScreenState extends State<ViewGroupsScreen> {
  List<Map<String, dynamic>> organiserGroups = [];
  List<Map<String, dynamic>> memberGroups = [];
  Map<String, dynamic> userCache = {};
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null) return;
    currentUserId = userId;

    final url = Uri.parse(
      "https://sportface-f9594-default-rtdb.firebaseio.com/groups.json",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      final List<Map<String, dynamic>> organiser = [];
      final List<Map<String, dynamic>> member = [];

      data.forEach((key, value) {
        final createdBy = value['createdBy'];
        final List members = value['members'] ?? [];

        if (createdBy == userId) {
          organiser.add({"id": key, ...value});
        } else if (members.contains(userId)) {
          member.add({"id": key, ...value});
        }
      });

      setState(() {
        organiserGroups = organiser;
        memberGroups = member;
      });
    }
  }

  Future<void> updateGroupRequest(
    String groupId,
    String userId,
    bool accept,
  ) async {
    final groupRef =
        "https://sportface-f9594-default-rtdb.firebaseio.com/groups/$groupId";

    await http.delete(Uri.parse("$groupRef/requests/$userId.json"));

    if (accept) {
      final memberRef = Uri.parse("$groupRef/members.json");

      final currentMembersRes = await http.get(memberRef);
      List<dynamic> currentMembers = [];
      if (currentMembersRes.statusCode == 200) {
        final resData = jsonDecode(currentMembersRes.body);
        if (resData is List) {
          currentMembers = resData;
        } else if (resData is Map) {
          currentMembers = resData.values.toList();
        }
      }

      if (!currentMembers.contains(userId)) {
        currentMembers.add(userId);
        await http.put(memberRef, body: jsonEncode(currentMembers));
      }

      // Mark accepted in user's profile
      await http.put(
        Uri.parse(
          'https://sportface-f9594-default-rtdb.firebaseio.com/users/$userId/groupRequests/$groupId.json',
        ),
        body: jsonEncode({"status": "accepted"}),
      );
    } else {
      // Mark rejected
      await http.put(
        Uri.parse(
          'https://sportface-f9594-default-rtdb.firebaseio.com/users/$userId/groupRequests/$groupId.json',
        ),
        body: jsonEncode({"status": "rejected"}),
      );
    }

    fetchGroups();
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    if (userCache.containsKey(userId)) return userCache[userId];

    final url = Uri.parse(
      "https://sportface-f9594-default-rtdb.firebaseio.com/users/$userId.json",
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      userCache[userId] = data;
      return data;
    }
    return null;
  }

  void showUserProfilePopup(BuildContext context, Map<String, dynamic>? user) {
    if (user == null) return;
    showDialog(
      context: context,
      builder:
          (_) => ProfileScreenLite(
            name: user['name'] ?? 'N/A',
            email: user['email'] ?? 'N/A',
            age: user['age']?.toString() ?? 'N/A',
            imageUrl: user['imageUrl'],
          ),
    );
  }

  Widget buildGroupCard(
    Map<String, dynamic> group, {
    bool isOrganiser = false,
  }) {
    final groupId = group['id'];
    final groupName = group['groupName'] ?? 'Unnamed';
    final List<dynamic> members = List<dynamic>.from(group['members'] ?? []);
    final Map<String, dynamic> requests = Map<String, dynamic>.from(
      group['requests'] ?? {},
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isOrganiser && requests.isNotEmpty) ...[
              const Text(
                "Join Requests:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Column(
                children:
                    requests.keys.map((userId) {
                      return FutureBuilder(
                        future: fetchUserProfile(userId),
                        builder: (context, snapshot) {
                          final user = snapshot.data as Map<String, dynamic>?;

                          return ListTile(
                            leading: GestureDetector(
                              onTap: () => showUserProfilePopup(context, user),
                              child: CircularAvatar(
                                userId: userId,
                                imageUrl: user?['imageUrl'] ?? '',
                              ),
                            ),
                            title: Text(user?['name'] ?? 'User ID: $userId'),
                            subtitle: Text(user?['email'] ?? ''),
                            trailing: Wrap(
                              spacing: 10,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed:
                                      () => updateGroupRequest(
                                        groupId,
                                        userId,
                                        true,
                                      ),
                                  tooltip: "Approve",
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => updateGroupRequest(
                                        groupId,
                                        userId,
                                        false,
                                      ),
                                  tooltip: "Reject",
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
              const Divider(),
            ],
            const Text(
              "Group Members:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  members.map((uid) {
                    return FutureBuilder(
                      future: fetchUserProfile(uid),
                      builder: (context, snapshot) {
                        final user = snapshot.data as Map<String, dynamic>?;
                        return CircularAvatar(
                          userId: uid,
                          imageUrl: user?['imageUrl'] ?? '',
                        );
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatScreen(
                            groupId: groupId,
                            groupName: groupName,
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat),
                label: const Text("Chat"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Groups")),
      body: RefreshIndicator(
        onRefresh: fetchGroups,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Groups You Organise",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (organiserGroups.isEmpty)
                const Text("You have not created any groups yet."),
              ...organiserGroups.map(
                (g) => buildGroupCard(g, isOrganiser: true),
              ),
              const SizedBox(height: 24),
              Text(
                "Groups You Joined",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (memberGroups.isEmpty)
                const Text("You have not joined any groups yet."),
              ...memberGroups.map((g) => buildGroupCard(g, isOrganiser: false)),
            ],
          ),
        ),
      ),
    );
  }
}
