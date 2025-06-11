import 'package:flutter/material.dart';
import 'package:wyidziomka/pocketbase_service.dart';
import 'package:wyidziomka/login_screen.dart';
import 'package:wyidziomka/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;

  void _onLoginSuccess() {
    setState(() {
      _loggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _loggedIn ? const ChatScreen() : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}
