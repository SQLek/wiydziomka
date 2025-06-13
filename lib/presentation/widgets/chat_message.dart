

import 'package:flutter/material.dart';
import 'package:wyidziomka/data/models/message_model.dart';

class ChatMessage extends StatelessWidget {
  final MessageModel msg;

  const ChatMessage({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(msg.text), // Replace with Markdown widget in the future
            // Optionally show the id for debugging
            // Text('id: ${msg.id}', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
