import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/pocketbase_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late final PocketBaseService _pbService;
  int _selectedIndex = 1; // Default to middle selected
  String? _chatId; // Store the current chat id

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pbService = Provider.of<PocketBaseService>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await _pbService.getMessages();
      setState(() {
        _messages.clear();
        _messages.addAll(
          msgs.map((m) => {
            'id': m['id'] ?? '',
            'role': m['role'] ?? '',
            'text': m['text'] ?? ''
          }),
        );
      });
    } catch (e) {}
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // If this is the first message, create a chat first
    if (_messages.isEmpty || _chatId == null) {
      // Get the selected persona id and systemPrompt
      final personas = await _pbService.pb.collection('personas').getFullList();
      final personaId = personas[_selectedIndex].get<String>('id');
      final systemPrompt = personas[_selectedIndex].get<String>('systemPrompt');
      final userId = _pbService.pb.authStore.record?.get<String>('id');
      final chat = await _pbService.pb
          .collection('chats')
          .create(body: {'user': userId, 'persona': personaId});
      _chatId = chat.id;

      // sumbscribe to new messages with same _chatId
      _pbService.pb.collection('messages').subscribe('*', (event) {
        final record = event.record;
        if (record?.get<String>('chat') == _chatId) {
          setState(() {
            _messages.add({
              'role': record?.get<String>('role') ?? '',
              'text': record?.get<String>('text') ?? '',
            });
          });
        }
      });

      // Insert system message with systemPrompt
      if (systemPrompt.isNotEmpty) {
        await _pbService.pb
            .collection('messages')
            .create(
              body: {'text': systemPrompt, 'role': 'system', 'chat': _chatId},
            );
      }
    }

    setState(() {
      _messages.add({'id': '', 'role': 'user', 'text': text});
    });
    // Create message with chat relation
    await _pbService.pb
        .collection('messages')
        .create(body: {'text': text, 'role': 'user', 'chat': _chatId});
    _controller.clear();
  }

  Widget _buildSelectionPanel() {
    return PersonaSelector(
      selectedIndex: _selectedIndex,
      onSelect: (i) {
        setState(() {
          _selectedIndex = i;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildSelectionPanel()
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ChatMessage(
                        id: msg['id'] ?? '',
                        role: msg['role'] ?? '',
                        text: msg['text'] ?? '',
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
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

class ChatMessage extends StatelessWidget {
  final String id;
  final String role;
  final String text;

  const ChatMessage({
    super.key,
    required this.id,
    required this.role,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text), // Replace with Markdown widget in the future
            // Optionally show the id for debugging
            // Text('id: $id', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class PersonaIcon extends StatelessWidget {
  final String? avatarUrl;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PersonaIcon({
    super.key,
    this.avatarUrl,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.deepPurple : Colors.grey,
                width: selected ? 3 : 1,
              ),
            ),
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: selected ? 32 : 28,
                    backgroundImage: NetworkImage(avatarUrl!),
                  )
                : Icon(
                    Icons.person,
                    size: selected ? 64 : 56,
                    color: selected ? Colors.deepPurple : Colors.grey,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.deepPurple : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class PersonaSelector extends StatefulWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const PersonaSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  State<PersonaSelector> createState() => _PersonaSelectorState();
}

class _PersonaSelectorState extends State<PersonaSelector> {
  List<Map<String, dynamic>> _personas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPersonas();
  }

  Future<void> _loadPersonas() async {
    try {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final result = await pbService.pb.collection('personas').getFullList();
      setState(() {
        _personas = result.map((r) => r.toJson()).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_personas.isEmpty) {
      return const Center(child: Text('No personas found'));
    }
    return Center(
      child: Consumer<PocketBaseService>(
        builder: (context, pbService, _) {
          final baseUrl = pbService.pb.baseUrl;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_personas.length, (i) {
              final persona = _personas[i];
              String? avatarUrl;
              if (persona['avatar'] != null && persona['avatar'].isNotEmpty) {
                avatarUrl =
                    '$baseUrl/api/files/personas/${persona['id']}/${persona['avatar']}';
              }
              return PersonaIcon(
                avatarUrl: avatarUrl,
                label: persona['name'] ?? '',
                selected: i == widget.selectedIndex,
                onTap: () => widget.onSelect(i),
              );
            }),
          );
        },
      ),
    );
  }
}
