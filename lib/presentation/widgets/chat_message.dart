import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wyidziomka/data/models/message_model.dart';

// Custom builder for <thinking> tag
class ThinkingBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String text = element.textContent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_empty, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: preferredStyle)),
        ],
      ),
    );
  }
}

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
        child: Markdown(
          data: msg.text,
          extensionSet: md.ExtensionSet.gitHubWeb,
          builders: {
            'thinking': ThinkingBuilder(),
          },
          shrinkWrap: true,
          selectable: true, // Enable text selection
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
