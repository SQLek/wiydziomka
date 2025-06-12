import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  late final PocketBase pb;

  PocketBaseService({String? baseUrl, AuthStore? authStore}) {
    final String url =
        baseUrl ??
        const String.fromEnvironment(
          'POCKETBASE_URL',
          defaultValue: 'http://localhost:8090',
        );
    pb = PocketBase(url, authStore: authStore);
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final result = await pb.collection('messages').getFullList();
    return result.map((r) => r.toJson()).toList();
  }

  Future<Map<String, dynamic>> createMessage(String text, String role) async {
    final record = await pb
        .collection('messages')
        .create(body: {'text': text, 'role': role});
    return record.toJson();
  }

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }
}
