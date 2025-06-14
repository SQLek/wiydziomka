import 'package:flutter/material.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/screens/login_screen.dart';
import 'package:wyidziomka/presentation/screens/chats_screen.dart';
import 'package:wyidziomka/presentation/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings, VoidCallback onLoginSuccess) {
    if (settings.name == '/login') {
      return MaterialPageRoute(
        builder: (_) => LoginScreen(onLoginSuccess: onLoginSuccess),
      );
    }
    if (settings.name == '/chats') {
      return MaterialPageRoute(
        builder: (_) => const ChatsScreen(),
      );
    }
    if (settings.name != null && settings.name!.startsWith('/chat')) {
      final uri = Uri.parse(settings.name!);
      final chatId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      return MaterialPageRoute(
        builder: (context) {
          if (chatId == null) {
            return const Scaffold(body: Center(child: Text('No chat id provided')));
          }
          final pbService = Provider.of<PocketBaseService>(context, listen: false);
          return FutureBuilder(
            future: pbService.pb.collection('chats').getOne(chatId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Scaffold(body: Center(child: Text('Error loading chat: \\${snapshot.error}')));
              }
              if (!snapshot.hasData) {
                return const Scaffold(body: Center(child: Text('Chat not found')));
              }
              // Optionally, convert snapshot.data to ChatModel if needed
              return ChatScreen(chatId: chatId);
            },
          );
        },
      );
    }
    return null;
  }
}
