import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/pocketbase_service.dart';
import 'package:wyidziomka/login_screen.dart';
import 'package:wyidziomka/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    Provider<PocketBaseService>(
      create: (_) => PocketBaseService(),
      child: MyApp(),
    ),);
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pb_auth_token');
    if (token != null && token.isNotEmpty) {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      pbService.pb.authStore.save(token, null); // null for model, you can load user info if needed
      setState(() {
        _loggedIn = true;
        _loading = false;
      });
    } else {
      setState(() {
        _loggedIn = false;
        _loading = false;
      });
    }
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
      home: _loggedIn ? const ChatScreen() : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}
