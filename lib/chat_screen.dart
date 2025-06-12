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
          msgs.map((m) => {'role': m['role'] ?? '', 'text': m['text'] ?? ''}),
        );
      });
    } catch (e) {}
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
    });
    _controller.clear();
    await _pbService.createMessage(text, 'user');
    final aiText = 'Why do you say: "$text"?';
    setState(() {
      _messages.add({'role': 'ai', 'text': aiText});
    });
    await _pbService.createMessage(aiText, 'ai');
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
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(msg['text'] ?? ''),
                        ),
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
