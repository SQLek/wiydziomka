import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart';

class PocketBaseService {
  late final PocketBase pb;

  PocketBaseService() {
    final String baseUrl = kIsWeb
      ? Uri.base.origin // Use current origin for PWA
      : 'http://localhost:8090'; // Use localhost for dev
    pb = PocketBase(baseUrl);
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
}
