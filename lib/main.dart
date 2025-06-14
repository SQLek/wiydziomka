import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/presentation/screens/chat_screen.dart';
import 'package:wyidziomka/presentation/screens/chats_screen.dart';
import 'package:wyidziomka/presentation/screens/login_screen.dart';
import 'package:wyidziomka/presentation/screens/new_chat_screen.dart';
import 'data/services/pocketbase_service.dart';
import 'data/services/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );

  final pbService = PocketBaseService(authStore: store);
  await pbService.restoreAuth(prefs);

  runApp(
    Provider<PocketBaseService>(
      create: (_) => pbService,
      child: ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(pbService),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  static Widget _buildChatScreen(BuildContext context, GoRouterState state) {
    final chatId = state.pathParameters['id'];
    if (chatId == null) {
      return const Center(child: Text('Chat ID not provided'));
    }

    final pbService = Provider.of<PocketBaseService>(context, listen: false);
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final GoRouter router = GoRouter(
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => NewChatScreen(),
        ),
        GoRoute(
          path: '/chats',
          builder: (context, state) => ChatsScreen(),
        ),
        GoRoute(
          path: '/chat/:id',
          builder: _buildChatScreen,
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
      ],
      redirect: (context, state) {
        final loggedIn = authProvider.loggedIn;
        final loggingIn = state.fullPath == '/login';
        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/';
        return null;
      },
    );
    return MaterialApp.router(
      routerConfig: router,
      title: 'GoRouter Example',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
