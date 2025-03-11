import 'package:flutter/material.dart';
import 'package:dermalens/models/user_model.dart';
import 'package:dermalens/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _user != null;

  bool get isInitialized => _isInitialized;

  // Inisialisasi - cek apakah user sudah login
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Coba auto login
      _user = await ApiService.autoLogin();
    } catch (e) {
      print('Auth initialization error: $e');
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Register - Menambahkan metode register
  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Panggil API untuk registrasi
      await ApiService.register(email, password, name);
      // Tidak perlu set user karena biasanya setelah register perlu login
      // atau akan otomatis login di halaman signup
    } catch (e) {
      // Re-throw exception agar bisa ditangkap oleh UI
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await ApiService.login(email, password);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile(
      {String? name, String? phone, String? avatar}) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await ApiService.updateProfile(
          name: name, phone: phone, avatar: avatar);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await ApiService.getProfile();
    } catch (e) {
      print('Failed to refresh user data: $e');
      // Jika gagal refresh, coba ambil dari cache
      _user = await ApiService.getUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
