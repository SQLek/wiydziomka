import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatDrawer extends StatelessWidget {
  final List<String> chats;
  const ChatDrawer({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Text('Chats', style: TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatId = chats[index];
                return ListTile(
                  title: Text('Chat $chatId'),
                  onTap: () {
                    context.go('/chat/$chatId');
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Chat'),
            onTap: () {
              context.go('/chat-new');
            },
          ),
        ],
      ),
    );
  }
}
