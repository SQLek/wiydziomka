import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/data/models/message_model.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/widgets/message_list.dart';
import 'package:wyidziomka/presentation/widgets/persona_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final PocketBaseService _pbService;
  late final Stream<List<MessageModel>> _messageStream;
  final GlobalKey<PersonaSelectorState> _personaSelectorKey = GlobalKey<PersonaSelectorState>();
  ChatModel? _activeChat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pbService = Provider.of<PocketBaseService>(context, listen: false);
    _messageStream = Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => _activeChat != null ? _pbService.getMessages() : Future.value([]));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
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

    await _pbService.pb
        .collection('messages')
        .create(body: {'text': text, 'role': 'user', 'chat': _activeChat!.id});
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Type your first message...'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: MessageList(messageStream: _messageStream),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Type a message...'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
