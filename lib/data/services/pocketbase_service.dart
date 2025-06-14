import 'package:pocketbase/pocketbase.dart';
import 'package:wyidziomka/data/models/message_model.dart';
import 'package:wyidziomka/data/models/persona_model.dart';
import 'package:wyidziomka/data/models/model_model.dart';

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

  Future<List<MessageModel>> getMessages() async {
    final result = await pb.collection('messages').getFullList();
    return result.map((r) => MessageModel.fromRecord(r)).toList();
  }

  Future<void> createMessage(String text, String role) async {
    try {
      await pb.collection('messages').create(body: {'text': text, 'role': role});
    } catch (e) {
      // Optionally, add logging here
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  Future<List<PersonaModel>> getPersonas() async {
    final result = await pb.collection('personas').getFullList();
    return result.map((record) {
      final avatarFilename = record.get<String>('avatar');
      final avatarUrl = pb.files.getURL(record, avatarFilename).toString();
      return PersonaModel(
        id: record.get<String>('id'),
        name: record.get<String>('name'),
        avatar: avatarUrl,
      );
    }).toList();
  }

  Future<List<ModelModel>> getModels({bool? isThinking, bool? isPreferred}) async {
    final filters = <String>[];
    if (isThinking != null) {
      filters.add('isThinking = ${isThinking ? "true" : "false"}');
    }
    if (isPreferred != null) {
      filters.add('isPreferred = ${isPreferred ? "true" : "false"}');
    }
    // Filter for active provider relation
    filters.add('provider.isActive = true');
    final filterString = filters.join(' && ');
    final result = await pb.collection('models').getFullList(
      filter: filterString.isNotEmpty ? filterString : null,
      expand: 'provider',
    );
    return result.map((r) => ModelModel.fromRecord(r)).toList();
  }
}
