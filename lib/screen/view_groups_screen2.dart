import 'package:flutter/material.dart';
import '../data/travel_data.dart';
import '../widgets/travel_card.dart';
import '../model/travel_model.dart';
import 'chat_travel.dart';

class ViewGroupsScreen extends StatefulWidget {
  final String currentUser;

  const ViewGroupsScreen({super.key, required this.currentUser});

  @override
  State<ViewGroupsScreen> createState() => _ViewGroupsScreenState();
}

class _ViewGroupsScreenState extends State<ViewGroupsScreen> {
  void _approveRequest(PendingRequest request) {
    final group = groupData.firstWhere((g) => g.groupId == request.groupId);
    setState(() {
      group.members.add(request.userName);
      pendingRequests.remove(request);
      print("Approved ${request.userName} for group: ${group.groupId}");
      logGroupData("After approval");
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Approved ${request.userName} to join!")),
    );
  }

  void _rejectRequest(PendingRequest request) {
    setState(() {
      final group = groupData.firstWhere((g) => g.groupId == request.groupId);
      pendingRequests.remove(request);
      print("Rejected ${request.userName} for group: ${group.groupId}");
      logGroupData("After rejection");
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rejected ${request.userName}'s request")),
    );
  }

  void _editGroupName(GroupModel group) {
    final controller = TextEditingController(text: group.groupName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Group Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Group Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index =
                    groupData.indexWhere((g) => g.groupId == group.groupId);
                groupData[index] = GroupModel(
                  groupId: group.groupId,
                  eventId: group.eventId,
                  groupName: controller.text.trim(),
                  organiserName: group.organiserName,
                  members: group.members,
                );
                print("Updated group name to: ${controller.text.trim()}");
                logGroupData("After name edit");
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("ViewGroupsScreen: currentUser = ${widget.currentUser}");
    logGroupData("Before filtering");
    final userGroups = groupData.where((group) {
      final isOrganiser =
          group.organiserName.toLowerCase() == widget.currentUser.toLowerCase();
      final isMember = group.members.contains(widget.currentUser);
      print(
          "Group ${group.groupId}: isOrganiser=$isOrganiser (organiserName=${group.organiserName}, currentUser=${widget.currentUser}), isMember=$isMember");
      return isOrganiser || isMember;
    }).toList();
    final organiserRequests = pendingRequests
        .where((req) => groupData.any((g) =>
            g.groupId == req.groupId &&
            g.organiserName.toLowerCase() == widget.currentUser.toLowerCase()))
        .toList();
    print(
        "User: ${widget.currentUser}, Groups: ${userGroups.length}, Requests: ${organiserRequests.length}");

    return Scaffold(
      appBar: AppBar(title: const Text("My Groups")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              userGroups.isEmpty
                  ? const Center(child: Text("No groups joined yet."))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userGroups.length,
                      itemBuilder: (context, index) {
                        final group = userGroups[index];
                        final event = travelData.firstWhere(
                          (e) => e.id == group.eventId,
                          orElse: () => TravelModel(
                            id: group.eventId,
                            sportName: "Unknown",
                            logoPath: "assets/images/default.jpg",
                            organiserName: group.organiserName,
                            venue: "Unknown",
                            city: "Unknown",
                            description: "Event not found",
                            date: "Unknown",
                            time: "Unknown",
                            gender: "Any",
                            ageLimit: "18-30",
                            paidStatus: "Unpaid",
                            latitude: 0.0,
                            longitude: 0.0,
                          ),
                        );
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.group, color: Colors.blue),
                                  title: Text(
                                    group.groupName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: group.organiserName.toLowerCase() ==
                                          widget.currentUser.toLowerCase()
                                      ? IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editGroupName(group),
                                        )
                                      : null,
                                ),
                                CompanionCard(
                                  data: event,
                                  currentUser: widget.currentUser,
                                  onReadMorePressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          groupId: group.groupId,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              if (organiserRequests.isNotEmpty) ...[
                const Text(
                  "Pending Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: organiserRequests.length,
                  itemBuilder: (context, index) {
                    final request = organiserRequests[index];
                    return ListTile(
                      leading: const Icon(Icons.person_add, color: Colors.blue),
                      title: Text("${request.userName} wants to join"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => _approveRequest(request),
                            child: const Text("Approve"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _rejectRequest(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
