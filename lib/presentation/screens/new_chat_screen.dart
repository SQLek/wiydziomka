import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/widgets/message_input.dart';
import 'package:wyidziomka/presentation/widgets/persona_selector.dart';
import 'package:wyidziomka/presentation/widgets/responsive_scaffold.dart';
import 'package:wyidziomka/presentation/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<PersonaSelectorState> _personaSelectorKey = GlobalKey<PersonaSelectorState>();
  bool _creating = false;

  void _handleSend(bool isThinking, String text) async {
    if (text.isEmpty || _creating) return;
    final personaSelectorState = _personaSelectorKey.currentState;
    if (personaSelectorState == null) {
      throw Exception('Invalid state');
    }
    setState(() { _creating = true; });
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    final chat = await personaSelectorState.createChat();
    await pbService.createMessage(
      text: text,
      role: 'user',
      chatId: chat.id,
      isThinking: isThinking,
    );
    setState(() { _creating = false; });
    if (mounted) {
      GoRouter.of(context).go('/chat/${chat.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          PersonaSelector(key: _personaSelectorKey),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MessageInput(
              controller: _controller,
              onSend: _handleSend,
              hintText: 'Type your first message...',
            ),
          ),
          if (_creating)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      drawerContent: const AppDrawer(),
    );
  }
}
