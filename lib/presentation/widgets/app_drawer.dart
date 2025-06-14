import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/data/services/auth_provider.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Estimate how many recent chats to show based on height
        final availableHeight = constraints.maxHeight;
        final headerHeight = 80.0;
        final tileHeight = 56.0;
        final staticTiles = 3; // New Chat, All Chats, Logout
        final maxRecentChats = ((availableHeight - headerHeight) / tileHeight).floor() - staticTiles;
        return FutureBuilder<List<ChatModel>>(
          future: pbService.getLatestChats(limit: maxRecentChats > 0 ? maxRecentChats : 0),
          builder: (context, snapshot) {
            final chats = snapshot.data ?? [];
            final recentChats = chats.take(maxRecentChats > 0 ? maxRecentChats : 0).toList();
            return ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Chat'),
                  onTap: () => GoRouter.of(context).go('/'),
                ),
                if (recentChats.isNotEmpty) ...[
                  const Divider(),
                  ...recentChats.map((chat) => ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(chat.name),
                        onTap: () => GoRouter.of(context).go('/chat/${chat.id}'),
                      )),
                ],
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('All Chats'),
                  onTap: () => GoRouter.of(context).go('/chats'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    GoRouter.of(context).go('/login');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
