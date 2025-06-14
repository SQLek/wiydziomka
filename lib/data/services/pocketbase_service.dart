import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:wyidziomka/data/models/message_model.dart';
import 'package:wyidziomka/data/models/persona_model.dart';
import 'package:wyidziomka/data/models/model_model.dart';
import 'package:wyidziomka/data/models/chat_model.dart';

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

  Future<List<MessageModel>> getMessages({String? chatId}) async {
    if (chatId != null) {
      final result = await pb.collection('messages').getFullList(
        filter: 'chat = "$chatId"',
      );
      return result.map((r) => MessageModel.fromRecord(r)).toList();
    } else {
      final result = await pb.collection('messages').getFullList();
      return result.map((r) => MessageModel.fromRecord(r)).toList();
    }
  }

  Future<void> createMessage({
    required String text,
    required String role,
    required String chatId,
    bool? isThinking,
  }) async {
    final body = {
      'text': text,
      'role': role,
      'chat': chatId,
      if (isThinking != null) 'isThinking': isThinking,
    };
    try {
      await pb.collection('messages').create(body: body);
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

  Future<ChatModel> createChat({
    required String personaId,
    String? preferredModelId,
    String? thinkingModelId,
  }) async {
    final userId = pb.authStore.record?.id;
    final body = {
      'persona': personaId,
      'user': userId,
      if (preferredModelId != null) 'preferredModel': preferredModelId,
      if (thinkingModelId != null) 'thinkingModel': thinkingModelId,
    };
    final record = await pb.collection('chats').create(body: body);
    return ChatModel.fromRecord(record);
  }

  /// Subscribe to messages for a chat using PocketBase realtime API.
  /// Returns a stream of MessageModel for new/updated messages in the chat.
  Future<Stream<MessageModel>> subscribeMessages(String chatId) async {
    final controller = StreamController<MessageModel>();
    late final Future<void> unsubFuture;
    unsubFuture = pb.collection('messages').subscribe('*', (e) {
      final record = e.record;
      if (record != null && (e.action == 'create' || e.action == 'update')) {
        if (record.get<String>('chat') == chatId) {
          controller.add(MessageModel.fromRecord(record));
        }
      }
    });
    controller.onCancel = () {
      unsubFuture;
    };
    // Optionally, fetch initial messages if needed
    return controller.stream;
  }

  Future<Stream<MessageModel>> subscribeMessagesRealtime(String chatId) async {
    final controller = StreamController<MessageModel>();
    final unsubFuture = pb.collection('messages').subscribe('*', (e) {
      final record = e.record;
      if (record != null && (e.action == 'create' || e.action == 'update')) {
        if (record.get<String>('chat') == chatId) {
          controller.add(MessageModel.fromRecord(record));
        }
      }
    });
    controller.onCancel = () {
      unsubFuture;
    };
    return controller.stream;
  }
}
