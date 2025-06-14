import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/app/config/theme.dart';
import 'package:wyidziomka/app/routing/app_router.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/data/services/auth_provider.dart';
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

  // Restore user record if token is valid
  await pbService.restoreAuth(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<PocketBaseService>.value(value: pbService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(pbService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Wiydziomka',
      theme: appTheme,
      initialRoute: auth.loggedIn ? '/chats' : '/login',
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings, () async {
        await auth.onLoginSuccess();
      }),
    );
  }
}
