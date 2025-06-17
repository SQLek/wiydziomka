import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:wiydziomka/data/models/message_model.dart';
import 'package:wiydziomka/data/models/persona_model.dart';
import 'package:wiydziomka/data/models/model_model.dart';
import 'package:wiydziomka/data/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        sort: 'created',
      );
      return result.map((r) => MessageModel.fromRecord(r)).toList();
    } else {
      final result = await pb.collection('messages').getFullList(sort: '-created');
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
        systemPrompt: record.get<String>('systemPrompt'),
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

  Future<ChatModel> getChat(String chatId) async {
    final record = await pb.collection('chats').getOne(chatId);
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

  /// Restores the user record if the auth token is valid.
  /// Returns true if restored, false if not.
  Future<bool> restoreAuth(SharedPreferences prefs) async {
    if (pb.authStore.isValid) {
      try {
        final userId = pb.authStore.model.id;
        if (userId != null) {
          final userRecord = await pb.collection('users').getOne(userId);
          final token = pb.authStore.token;
          pb.authStore.save(token, userRecord);
        }
        return true;
      } catch (e) {
        pb.authStore.clear();
        await prefs.remove('pb_auth');
        return false;
      }
    }
    return false;
  }

  /// Fetches the latest chats, limited by [limit].
  Future<List<ChatModel>> getLatestChats({int limit = 5}) async {
    final result = await pb.collection('chats').getList(page: 1, perPage: limit, sort: '-created');
    return result.items.map((r) {
      final name = r.get<String?>('name');
      final created = r.get<String>('created');
      return ChatModel(
        id: r.get<String>('id'),
        name: name == null || name.isEmpty ? 'Unnamed $created' : name,
        preferredModelId: r.get<String?>('preferredModel'),
        thinkingModelId: r.get<String?>('thinkingModel'),
      );
    }).toList();
  }

  /// Renames a chat by updating its name.
  Future<void> renameChat(String chatId, String newName) async {
    await pb.collection('chats').update(chatId, body: {'name': newName});
  }

  /// Deletes a chat by its ID.
  Future<void> deleteChat(String chatId) async {
    await pb.collection('chats').delete(chatId);
  }
}
