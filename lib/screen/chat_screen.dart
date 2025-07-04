import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatScreen({super.key, required this.groupId, required this.groupName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    validateAccess();
    listenToMessages();
  }

  Future<void> validateAccess() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null) return;

    final url = Uri.parse(
      'https://sportface-f9594-default-rtdb.firebaseio.com/groups/${widget.groupId}.json',
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List members = data['members'] ?? [];

        if (!members.contains(userId)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ You are not a member of this group.'),
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } else {
        debugPrint('❌ Failed to validate access: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ validateAccess error: $e');
    }
  }

  void listenToMessages() async {
    final url = Uri.parse(
      'https://sportface-f9594-default-rtdb.firebaseio.com/chats/${widget.groupId}.json',
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200 && mounted) {
        final Map<String, dynamic>? data = jsonDecode(res.body);
        final List<Map<String, dynamic>> tempMessages = [];

        data?.forEach((key, value) {
          tempMessages.add({
            'id': key,
            'text': value['text'],
            'senderId': value['senderId'],
            'timestamp': value['timestamp'],
          });
        });

        tempMessages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        setState(() {
          messages = tempMessages;
        });

        // Scroll to bottom
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('❌ listenToMessages error: $e');
    }
  }

  Future<void> sendMessage() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null || _controller.text.trim().isEmpty) return;

    final message = {
      "senderId": userId,
      "text": _controller.text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    final url = Uri.parse(
      'https://sportface-f9594-default-rtdb.firebaseio.com/chats/${widget.groupId}.json',
    );

    await http.post(url, body: jsonEncode(message));
    _controller.clear();
    listenToMessages();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserProvider>(context).user?.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['senderId'] == currentUserId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
