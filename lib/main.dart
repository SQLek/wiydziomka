import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import '../presentation/widgets/chat_drawer.dart';
import 'data/services/pocketbase_service.dart';

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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => RouteScreen(route: '/'),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => RouteScreen(route: '/chats'),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => RouteScreen(
          route: '/chat/${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/chat-new',
        builder: (context, state) => RouteScreen(route: '/chat-new'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Example',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class RouteScreen extends StatelessWidget {
  final String route;
  const RouteScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    // Example chat list
    final chats = ['123', '456', '789'];
    return Scaffold(
      appBar: AppBar(title: Text('Current Route')),
      drawer: ChatDrawer(chats: chats),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You are on: $route', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to /'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/chats'),
              child: const Text('Go to /chats'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/chat/123'),
              child: const Text('Go to /chat/123'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/chat-new'),
              child: const Text('Go to /chat-new'),
            ),
          ],
        ),
      ),
    );
  }
}
