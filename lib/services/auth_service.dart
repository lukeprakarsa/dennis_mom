import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import 'api_service.dart';

/// Authentication service that manages user login/logout state
class AuthService extends ChangeNotifier {
  AppUser? _currentUser;
  String? _token;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;
  bool get isLoading => _isLoading;

  /// Initialize the auth service and check for saved session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');

      if (savedToken != null) {
        // Verify token is still valid by fetching user info
        final response = await ApiService.get('/api/auth/me', token: savedToken);
        final data = ApiService.handleResponse(response);

        _token = savedToken;
        _currentUser = AppUser.fromJson(data['user']);
        print('✅ Restored user session: ${_currentUser?.email}');
      }
    } catch (e) {
      print('⚠️ Failed to restore session: $e');
      await _clearSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/auth/register',
        body: {
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final data = ApiService.handleResponse(response);

      _token = data['token'];
      _currentUser = AppUser.fromJson(data['user']);

      await _saveSession();

      print('✅ User registered: ${_currentUser?.email}');
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login an existing user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = ApiService.handleResponse(response);

      _token = data['token'];
      _currentUser = AppUser.fromJson(data['user']);

      await _saveSession();

      print('✅ User logged in: ${_currentUser?.email}');
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    await _clearSession();
    _currentUser = null;
    _token = null;
    notifyListeners();
    print('✅ User logged out');
  }

  /// Save session to local storage
  Future<void> _saveSession() async {
    if (_token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
    }
  }

  /// Clear session from local storage
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
