import 'package:flutter/material.dart';
import '../model/travel_model.dart';
import '../data/travel_data.dart';

class CompanionCard extends StatelessWidget {
  final TravelModel data;
  final VoidCallback onReadMorePressed;
  final String currentUser;

  const CompanionCard({
    Key? key,
    required this.data,
    required this.onReadMorePressed,
    required this.currentUser,
  }) : super(key: key);

  void _requestToJoin(BuildContext context) {
    print("RequestToJoin: currentUser=$currentUser, organiserName=${data.organiserName}");
    GroupModel? group;
    for (var g in groupData) {
      if (g.eventId == data.id) {
        group = g;
        break;
      }
    }
    if (group == null) {
      group = GroupModel(
        groupId: "group${groupData.length + 1}",
        eventId: data.id,
        groupName: "${data.sportName} Group by ${data.organiserName}",
        organiserName: data.organiserName,
        members: [data.organiserName],
      );
      groupData.add(group);
      print("Created new group: ${group.groupId} for event: ${group.eventId}");
      logGroupData("After group creation in request");
    }
    if (currentUser.toLowerCase() == data.organiserName.toLowerCase()) {
      if (!group.members.contains(currentUser)) {
        group.members.add(currentUser);
        print("Auto-added organiser $currentUser to group: ${group.groupId}");
        logGroupData("After auto-adding organiser");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are the organiser of this group!")),
      );
      return;
    }
    pendingRequests.add(PendingRequest(
      userName: currentUser,
      groupId: group.groupId,
    ));
    print("Added request for user: $currentUser to group: ${group.groupId}");
    logGroupData("After adding request");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request sent to organiser!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                data.logoPath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      Text(
                        data.sportName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      Text(
                        "by ${data.organiserName}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${data.venue}, ${data.city}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${data.date} at ${data.time}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoTag("Gender: ${data.gender}"),
                      _buildInfoTag("Type: ${data.paidStatus}"),
                      _buildInfoTag("Age Limit: ${data.ageLimit}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: onReadMorePressed,
                        child: const Text(
                          "Read More",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _requestToJoin(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                        
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("Request"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}
