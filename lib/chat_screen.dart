import 'package:flutter/material.dart';
import 'package:wyidziomka/pocketbase_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final PocketBaseService _pbService = PocketBaseService();
  int _selectedIndex = 1; // Default to middle selected

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
        _messages.addAll(msgs.map((m) => {
          'role': m['role'] ?? '',
          'text': m['text'] ?? '',
        }));
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
    final images = [
      Icons.emoji_emotions_outlined,
      Icons.emoji_objects_outlined,
      Icons.emoji_nature_outlined,
    ];
    final labels = [
      'Fun',
      'Smart',
      'Nature',
    ];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final selected = i == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = i;
                  });
                },
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
                  child: Icon(
                    images[i],
                    size: selected ? 64 : 56,
                    color: selected ? Colors.deepPurple : Colors.grey,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final selected = i == _selectedIndex;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.deepPurple : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
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
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
