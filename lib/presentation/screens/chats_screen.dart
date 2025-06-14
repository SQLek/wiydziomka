import 'package:flutter/material.dart';
import 'package:wyidziomka/presentation/widgets/responsive_scaffold.dart';
import 'package:wyidziomka/presentation/widgets/app_drawer.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: const Center(child: Text('Chats list goes here.')),
      drawerContent: const AppDrawer(),
    );
  }
}
