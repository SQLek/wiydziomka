import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart';

class PocketBaseService {
  late final PocketBase pb;

  PocketBaseService({String? baseUrl}) {
    // Use --dart-define=POCKETBASE_URL=... to set this at build/run time
    final String url = baseUrl ??
        const String.fromEnvironment('POCKETBASE_URL', defaultValue: 'http://localhost:8090');
    pb = PocketBase(url);
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final result = await pb.collection('messages').getFullList();
    return result.map((r) => r.toJson()).toList();
  }

  Future<Map<String, dynamic>> createMessage(String text, String role) async {
    final record = await pb.collection('messages').create(body: {
      'text': text,
      'role': role,
    });
    return record.toJson();
  }

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }
}
