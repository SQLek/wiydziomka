import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function(bool isThinking, String text) onSend;
  final String hintText;
  final bool thinkingMode;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
    this.thinkingMode = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late bool _thinkingMode;

  @override
  void initState() {
    super.initState();
    _thinkingMode = widget.thinkingMode;
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(_thinkingMode, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Custom switch with icon
        GestureDetector(
          // Toggle thinking mode
          onTap: () => setState(() => _thinkingMode = !_thinkingMode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _thinkingMode ? Colors.yellow[200] : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _thinkingMode ? Icons.lightbulb : Icons.lightbulb_outline,
              color: _thinkingMode ? Colors.amber[800] : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(hintText: widget.hintText),
            onSubmitted: (_) => _handleSend(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _handleSend,
        ),
      ],
    );
  }
}
