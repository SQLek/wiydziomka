import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiydziomka/data/models/chat_model.dart';
import 'package:wiydziomka/data/models/message_model.dart';
import 'package:wiydziomka/data/services/pocketbase_service.dart';

import 'chat_message.dart';

class MessageList extends StatefulWidget {
  final ChatModel chat;
  const MessageList({super.key, required this.chat});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late final PocketBaseService _pbService;
  StreamSubscription? _subscription;

  List<MessageModel> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pbService = Provider.of<PocketBaseService>(context, listen: false);
    _loadInitialMessagesAndSubscribe();
  }

  Future<void> _loadInitialMessagesAndSubscribe() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final initial = await _pbService.getMessages(chatId: widget.chat.id);
      setState(() {
        _messages = initial;
        _loading = false;
      });
      final stream = await _pbService.subscribeMessages(widget.chat.id);
      _subscription = stream.listen((msg) {
        setState(() {
          // Replace or add message by id
          final idx = _messages.indexWhere((m) => m.id == msg.id);
          if (idx >= 0) {
            _messages[idx] = msg;
          } else {
            _messages.add(msg);
          }
        });
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load messages.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet.'));
    }
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[_messages.length - 1 - index];
        return ChatMessage(msg: msg);
      },
    );
  }
}
