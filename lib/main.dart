import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/pocketbase_service.dart';
import 'package:wyidziomka/login_screen.dart';
import 'package:wyidziomka/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );

  final pbService = PocketBaseService(authStore: store);

  // Try to restore user record if token is valid
  if (pbService.pb.authStore.isValid) {
    try {
      final userId = pbService.pb.authStore.model.id;
      if (userId != null) {
        final userRecord = await pbService.pb
            .collection('users')
            .getOne(userId);
        final token = pbService.pb.authStore.token;
        pbService.pb.authStore.save(token, userRecord);
      }
    } catch (e) {
      pbService.pb.authStore.clear();
      await prefs.remove('pb_auth');
    }
  }

  runApp(Provider<PocketBaseService>.value(value: pbService, child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    setState(() {
      _loggedIn = pbService.pb.authStore.isValid;
      _loading = false;
    });
  }

  void _onLoginSuccess() async {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    final token = pbService.pb.authStore.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pb_auth_token', token);
    setState(() {
      _loggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _loggedIn
          ? const ChatScreen()
          : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}
