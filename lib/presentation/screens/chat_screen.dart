import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  int _selectedIndex = 0;
  String? _chatId;
  late final Stream<List<MessageModel>> _messageStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pbService = Provider.of<PocketBaseService>(context, listen: false);
    _messageStream = Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => _chatId != null ? _pbService.getMessages() : Future.value([]));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_chatId == null) {
      // Get personas and create chat
      final personas = await _pbService.getPersonas();
      final persona = personas[_selectedIndex];
      final userId = _pbService.pb.authStore.record?.get<String>('id');
      final chat = await _pbService.pb
          .collection('chats')
          .create(body: {'user': userId, 'persona': persona.id});
      _chatId = chat.id;
      // Optionally send system prompt if you have it
    }

    await _pbService.pb
        .collection('messages')
        .create(body: {'text': text, 'role': 'user', 'chat': _chatId});
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _chatId == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                PersonaSelector(
                  selectedIndex: _selectedIndex,
                  onSelect: (i) {
                    setState(() {
                      _selectedIndex = i;
                    });
                  },
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
