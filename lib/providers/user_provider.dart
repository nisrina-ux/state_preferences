import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => _favorites;

  UserProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    final currentCount = prefs.getInt('visit_count') ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt('visit_count', newCount);

    final favorites = prefs.getStringList('favorites') ?? [];

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isDarkMode = isDarkMode;
    _visitCount = newCount;
    _favorites = favorites;
    _isLoading = false;

    notifyListeners();
  }

  Future<bool> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    
    // Latihan 5: Validasi Keamanan pada saveProfile
    // 1. Cek karakter berbahaya (<script> dsb)
    final scriptRegex = RegExp(r'<[^>]*>|script', caseSensitive: false);
    if (scriptRegex.hasMatch(newUser.name) || scriptRegex.hasMatch(newUser.email)) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Input mengandung karakter terlarang / berbahaya!');
    }

    // 2. Simpan data user
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> addFavorite(String item) async {
    if (item.trim().isEmpty || _favorites.contains(item)) return;
    final prefs = await SharedPreferences.getInstance();
    _favorites.add(item.trim());
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  Future<void> removeFavorite(String item) async {
    final prefs = await SharedPreferences.getInstance();
    _favorites.remove(item);
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }
}