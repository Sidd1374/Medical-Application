import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isLoadingUserData = false;
  bool _userDataLoadFailed = false;
  String? _errorMessage;
  bool _isTestMode = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoadingUserData => _isLoadingUserData;
  bool get userDataLoadFailed => _userDataLoadFailed;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isTestMode || _authService.isAuthenticated;
  bool get isTestMode => _isTestMode;
  String? get userRole => _userData?['role'];
  String? get userId =>
      _isTestMode ? 'test-user-id' : _authService.currentUser?.uid;
  String? get userName => _userData?['name'];

  void enterTestMode(String role) {
    _isTestMode = true;
    String name = 'Test Patient';
    if (role == 'admin') {
      name = 'Test Admin';
    }
    _userData = {
      'name': name,
      'email': 'test@test.com',
      'phone': '0000000000',
      'role': role,
    };
    _isLoading = false;
    _isLoadingUserData = false;
    _userDataLoadFailed = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_isLoadingUserData) return;
    _isLoadingUserData = true;
    _userDataLoadFailed = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _userData = await _authService.getCurrentUserData().timeout(
        const Duration(seconds: 15),
      );

      if (_userData == null && isAuthenticated) {
        _userDataLoadFailed = true;
        _errorMessage = 'User profile not found in database';
      }
    } catch (e) {
      _userDataLoadFailed = true;
      _errorMessage = 'Failed to load user data: ${e.toString()}';
    }

    _isLoadingUserData = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      await loadUserData();

      if (_userData == null) {
        _errorMessage = 'Login successful but user profile not found';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_isTestMode == false) {
        await _authService.logout();
      }
    } catch (e) {
      _errorMessage = 'Logout failed';
    }
    _isTestMode = false;
    _userData = null;
    _userDataLoadFailed = false;
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String phone) async {
    _isLoading = true;
    notifyListeners();

    if (_isTestMode) {
      _userData = {
        'name': name,
        'email': _userData?['email'],
        'phone': phone,
        'role': _userData?['role'],
      };
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      await _authService.updateUserProfile(
        userId: userId!,
        name: name,
        phone: phone,
      );
      await loadUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
