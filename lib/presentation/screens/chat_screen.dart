import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/widgets/message_input.dart';
import 'package:wyidziomka/presentation/widgets/message_list.dart';
import 'package:wyidziomka/presentation/widgets/persona_selector.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final PocketBaseService _pbService;
  final GlobalKey<PersonaSelectorState> _personaSelectorKey = GlobalKey<PersonaSelectorState>();
  late ChatModel _activeChat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pbService = Provider.of<PocketBaseService>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _activeChat = widget.chat;
  }

  void _handleSend(bool isThinking, String text) async {
    if (text.isEmpty) return;

    await _pbService.createMessage(
      text: text,
      role: 'user',
      chatId: _activeChat.id,
      isThinking: isThinking,
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: MessageList(chat: _activeChat),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MessageInput(
              controller: _controller,
              onSend: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}
