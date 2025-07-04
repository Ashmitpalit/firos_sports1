import 'package:flutter/material.dart';
import '../data/food_data.dart';
import '../model/food_model.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String currentUser;

  const ChatScreen({super.key, required this.groupId, required this.currentUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        groupMessages[widget.groupId] ??= [];
        groupMessages[widget.groupId]!.add(
          MessageModel(
            sender: widget.currentUser,
            text: _messageController.text,
            timestamp: DateTime.now().toString(),
          ),
        );
        _messageController.clear();
        print("Sent message in group: ${widget.groupId} by ${widget.currentUser}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = groupMessages[widget.groupId] ?? [];
    final group = groupData.firstWhere((g) => g.groupId == widget.groupId);

    if (!group.members.contains(widget.currentUser)) {
      return Scaffold(
        appBar: AppBar(title: Text(group.groupName)),
        body: const Center(child: Text("You are not a member of this group.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(group.groupName)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages yet."))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.sender == widget.currentUser;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Align(
                          alignment:
                              isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.deepPurple : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.sender,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.timestamp,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
