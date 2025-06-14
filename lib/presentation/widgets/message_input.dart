import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...'
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
            onSubmitted: (_) => onSend(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: onSend,
        ),
      ],
    );
  }
}
