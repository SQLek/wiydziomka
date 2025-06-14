import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/app/app_router.dart';
import 'package:wyidziomka/data/services/auth_provider.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:go_router/go_router.dart';

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final pbService = context.read<PocketBaseService>();
    _router = createRouter(authProvider, pbService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter PocketBase Chat',
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
