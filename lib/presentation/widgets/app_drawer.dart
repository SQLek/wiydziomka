import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wiydziomka/data/models/chat_model.dart';
import 'package:wiydziomka/data/services/auth_provider.dart';
import 'package:wiydziomka/data/services/pocketbase_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Future<List<ChatModel>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    // Do not call _refreshChats here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshChats();
  }

  void _refreshChats() {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    final availableHeight = MediaQuery.of(context).size.height;
    final headerHeight = 80.0;
    final tileHeight = 56.0;
    final staticTiles = 3;
    final maxRecentChats = ((availableHeight - headerHeight) / tileHeight).floor() - staticTiles;
    _chatsFuture = pbService.getLatestChats(limit: maxRecentChats > 0 ? maxRecentChats : 0);
  }

  @override
  Widget build(BuildContext context) {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final headerHeight = 80.0;
        final tileHeight = 56.0;
        final staticTiles = 3;
        final maxRecentChats = ((availableHeight - headerHeight) / tileHeight).floor() - staticTiles;
        return FutureBuilder<List<ChatModel>>(
          future: _chatsFuture, // Use the field here
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              tooltip: 'Rename',
                              onPressed: () async {
                                final controller = TextEditingController(text: chat.name);
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Rename Chat'),
                                    content: TextField(
                                      controller: controller,
                                      autofocus: true,
                                      decoration: const InputDecoration(hintText: 'Enter new chat name'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(controller.text),
                                        child: const Text('Rename'),
                                      ),
                                    ],
                                  ),
                                );
                                if (result != null && result.trim().isNotEmpty && result != chat.name) {
                                  await pbService.renameChat(chat.id, result.trim());
                                  setState(_refreshChats);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Chat'),
                                    content: Text('Are you sure you want to delete "${chat.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await pbService.deleteChat(chat.id);
                                  setState(_refreshChats);
                                }
                              },
                            ),
                          ],
                        ),
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
