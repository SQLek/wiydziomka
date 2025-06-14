import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wyidziomka/data/services/auth_provider.dart';
import 'package:wyidziomka/presentation/screens/login_screen.dart';
import 'package:wyidziomka/presentation/screens/chats_screen.dart';
import 'package:wyidziomka/presentation/screens/chat_screen.dart';
import 'package:wyidziomka/presentation/screens/new_chat_screen.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';

GoRouter createRouter(AuthProvider auth, PocketBaseService pbService) {
  return GoRouter(
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(onLoginSuccess: () async {
          await auth.onLoginSuccess();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
        }),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ChatsScreen(),
      ),
      GoRoute(
        path: '/chat-new',
        builder: (context, state) => const NewChatScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          return FutureBuilder<ChatModel>(
            future: pbService.getChat(chatId),
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
              return ChatScreen(chat: snapshot.data!);
            },
          );
        },
      ),
    ],
    redirect: (context, state) {
      print('Redirecting: \\${state.fullPath}');
      final loggedIn = auth.loggedIn;
      final loggingIn = state.fullPath == '/login';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
  );
}
