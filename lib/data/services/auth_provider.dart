import 'package:flutter/material.dart';
import 'package:wiydziomka/data/services/pocketbase_service.dart';

class AuthProvider extends ChangeNotifier {
  final PocketBaseService pbService;
  bool _loggedIn;
  bool _loading = true;

  AuthProvider(this.pbService)
      : _loggedIn = pbService.pb.authStore.isValid {
    _loading = false;
  }

  bool get loggedIn => _loggedIn;
  bool get loading => _loading;

  Future<void> checkLoginStatus() async {
    _loggedIn = pbService.pb.authStore.isValid;
    _loading = false;
    notifyListeners();
  }

  Future<void> onLoginSuccess() async {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    pbService.pb.authStore.clear();
    _loggedIn = false;
    notifyListeners();
  }
}
