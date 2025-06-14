import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/widgets/message_input.dart';
import 'package:wyidziomka/presentation/widgets/message_list.dart';
import 'package:wyidziomka/presentation/widgets/persona_selector.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  const ChatScreen({super.key, this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final PocketBaseService _pbService;
  final GlobalKey<PersonaSelectorState> _personaSelectorKey = GlobalKey<PersonaSelectorState>();
  ChatModel? _activeChat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pbService = Provider.of<PocketBaseService>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.chatId != null) {
      // Optionally, fetch chat by id and set _activeChat
      // For now, just set a placeholder or leave null for empty chat
    }
  }

  void _handleSend(bool isThinking, String text) async {
    if (text.isEmpty) return;

    if (_activeChat == null) {
      final personaSelectorState = _personaSelectorKey.currentState;
      if (personaSelectorState == null) {
        throw Exception('Invalid state');
      }

      final chat = await personaSelectorState.createChat();
      setState(() {
        _activeChat = chat;
      });
      // Optionally, call a callback to notify parent about active chat
    }

    await _pbService.createMessage(
      text: text,
      role: 'user',
      chatId: _activeChat!.id,
      isThinking: isThinking,
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _activeChat == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                PersonaSelector(
                  key: _personaSelectorKey,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MessageInput(
                    controller: _controller,
                    onSend: _handleSend,
                    hintText: 'Type your first message...',
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: MessageList(chat: _activeChat!),
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
