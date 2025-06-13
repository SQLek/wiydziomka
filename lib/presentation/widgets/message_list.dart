import 'package:flutter/material.dart';
import 'package:wyidziomka/data/models/message_model.dart';
import 'chat_message.dart';

class MessageList extends StatelessWidget {
  final Stream<List<MessageModel>> messageStream;

  const MessageList({super.key, required this.messageStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        final messages = snapshot.data!;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[messages.length - 1 - index];
            return ChatMessage(msg: msg);
          },
        );
      },
    );
  }
}
