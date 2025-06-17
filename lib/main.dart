import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:wiydziomka/data/models/chat_model.dart';
import 'package:wiydziomka/presentation/screens/chat_screen.dart';
import 'package:wiydziomka/presentation/screens/chats_screen.dart';
import 'package:wiydziomka/presentation/screens/login_screen.dart';
import 'package:wiydziomka/presentation/screens/new_chat_screen.dart';
import 'data/services/pocketbase_service.dart';
import 'data/services/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );

  final pbService = await PocketBaseService.create(authStore: store);
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
  const MyApp({super.key});

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
                return Scaffold(
                  appBar: AppBar(title: const Text('Chat')),
                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const DrawerHeader(
                          decoration: BoxDecoration(color: Colors.blue),
                          child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                        ),
                        ListTile(
                          leading: const Icon(Icons.chat),
                          title: const Text('New Chat'),
                          onTap: () {
                            Navigator.of(context).pop();
                            GoRouter.of(context).go('/');
                          },
                        ),
                      ],
                    ),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading chat:\n\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Start New Chat'),
                          onPressed: () {
                            GoRouter.of(context).go('/');
                          },
                        ),
                      ],
                    ),
                  ),
                );
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
      title: 'Wiydziomka',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
