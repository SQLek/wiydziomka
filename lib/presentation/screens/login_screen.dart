import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiydziomka/data/services/pocketbase_service.dart';
import 'package:wiydziomka/data/services/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _baseUrlController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('base_url');
      if (url != null) {
        _baseUrlController.text = url;
      }
    }
  }

  Future<void> _saveBaseUrl(String url) async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('base_url', url);
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      PocketBaseService pbService;
      final existingPbService = Provider.of<PocketBaseService>(context, listen: false);
      final authStore = existingPbService.pb.authStore;
      if (!kIsWeb && _baseUrlController.text.isNotEmpty) {
        await _saveBaseUrl(_baseUrlController.text);
        pbService = await PocketBaseService.create(
          baseUrl: _baseUrlController.text,
          authStore: authStore,
        );
      } else {
        pbService = existingPbService;
      }
      await pbService.login(_emailController.text, _passwordController.text);
      Provider.of<AuthProvider>(context, listen: false).onLoginSuccess();
    } catch (e) {
      setState(() {
        _error = 'Login failed';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!kIsWeb)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                        labelText: 'Base URL', counterText: ''),
                    maxLength: 100,
                  ),
                ),
              ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', counterText: ''),
                  maxLength: 20,
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password', counterText: ''),
                  obscureText: true,
                  maxLength: 20,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
