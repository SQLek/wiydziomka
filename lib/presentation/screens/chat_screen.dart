import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiydziomka/data/models/chat_model.dart';
import 'package:wiydziomka/data/services/pocketbase_service.dart';
import 'package:wiydziomka/presentation/widgets/message_input.dart';
import 'package:wiydziomka/presentation/widgets/message_list.dart';
import 'package:wiydziomka/presentation/widgets/responsive_scaffold.dart';
import 'package:wiydziomka/presentation/widgets/app_drawer.dart';

class ChatScreen extends StatelessWidget {
  final ChatModel chat;
  const ChatScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final PocketBaseService pbService = Provider.of<PocketBaseService>(context, listen: false);

    void handleSend(bool isThinking, String text) async {
      if (text.isEmpty) return;
      await pbService.createMessage(
        text: text,
        role: 'user',
        chatId: chat.id,
        isThinking: isThinking,
      );
      controller.clear();
    }

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: MessageList(chat: chat),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MessageInput(
              controller: controller,
              onSend: handleSend,
            ),
          ),
        ],
      ),
      drawerContent: const AppDrawer(),
    );
  }
}
