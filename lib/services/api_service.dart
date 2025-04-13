import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dermalens/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan URL API Anda
  // static const String baseUrl =  'http://10.0.2.2:3000/api'; // Untuk emulator Android
  // static const String baseUrl = 'http://localhost:3000/api'; // Untuk iOS simulator
  // static const String baseUrl = 'https://your-api-url.com/api'; // Untuk produksi
  static const String baseUrl =
      'https://api-dermalens-ta-04-kangphps-projects.vercel.app/api'; // Untuk produksi

  // Headers untuk request
  static Map<String, String> _headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Menyimpan token ke SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Mengambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Menyimpan data user
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Mengambil data user
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  // Menghapus semua data sesi (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Register - Metode baru untuk AuthProvider
  static Future<void> register(
      String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      // Debug: Cetak respons untuk melihat struktur data
      print('Register response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Registration failed');
      }

      // Registrasi berhasil, tidak perlu mengembalikan apa-apa
      // karena login akan dilakukan secara terpisah
    } catch (e) {
      print('Register error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid response from server.');
      }
      rethrow;
    }
  }

  // Signup - Tetap dipertahankan untuk kompatibilitas
  static Future<Map<String, dynamic>> signup(
      String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      // Debug: Cetak respons untuk melihat struktur data
      print('Signup response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Signup failed');
      }

      return data;
    } catch (e) {
      print('Signup error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid response from server.');
      }
      rethrow;
    }
  }

  // Login
  static Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Debug: Cetak respons untuk melihat struktur data
      print('Login response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      // Periksa struktur data
      if (data['user'] == null) {
        throw Exception('Invalid response: user data is missing');
      }

      // Simpan token
      if (data['token'] != null) {
        await saveToken(data['token']);
      } else {
        throw Exception('Invalid response: token is missing');
      }

      // Pastikan data user adalah Map
      if (data['user'] is! Map<String, dynamic>) {
        throw Exception('Invalid user data format');
      }

      // Buat objek user
      final user = UserModel.fromJson(data['user']);

      // Simpan data user
      await saveUser(user);

      return user;
    } catch (e) {
      print('Login error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid response from server.');
      }
      rethrow;
    }
  }

  // Get Profile
  static Future<UserModel> getProfile() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers(token: token),
      );

      // Debug: Cetak respons untuk melihat struktur data
      print('Profile response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          // Token expired
          await clearSession();
          throw Exception('Session expired. Please login again.');
        }
        throw Exception(data['message'] ?? 'Failed to get profile');
      }

      // Buat objek user
      final user = UserModel.fromJson(data['user']);

      // Update data user di local storage
      await saveUser(user);

      return user;
    } catch (e) {
      print('Get profile error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid response from server.');
      }
      rethrow;
    }
  }

  // Update Profile
  static Future<UserModel> updateProfile(
      {String? name, String? phone, String? avatar}) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (avatar != null) body['avatar'] = avatar;

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers(token: token),
        body: jsonEncode(body),
      );

      // Debug: Cetak respons untuk melihat struktur data
      print('Update profile response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          // Token expired
          await clearSession();
          throw Exception('Session expired. Please login again.');
        }
        throw Exception(data['message'] ?? 'Failed to update profile');
      }

      // Ambil data user yang diperbarui
      final updatedUser = await getProfile();

      return updatedUser;
    } catch (e) {
      print('Update profile error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid response from server.');
      }
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final token = await getToken();

      if (token == null) {
        // Jika tidak ada token, cukup hapus dari local storage
        await clearSession();
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers(token: token),
      );

      // Debug: Cetak respons untuk melihat struktur data
      print('Logout response: ${response.body}');

      // Hapus token dan data user dari local storage terlepas dari respons server
      await clearSession();

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Logout failed');
      }
    } catch (e) {
      // Tetap hapus token dan data user meskipun terjadi error
      await clearSession();

      print('Logout error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Invalid response from server.');
      }
      rethrow;
    }
  }

  // Auto login - mencoba login dengan token yang tersimpan
  static Future<UserModel?> autoLogin() async {
    try {
      // Cek apakah ada token
      final token = await getToken();
      if (token == null) {
        return null;
      }

      // Coba ambil data user dari local storage dulu
      final cachedUser = await getUser();

      // Coba validasi token dengan mengambil profil
      try {
        final user = await getProfile();
        return user;
      } catch (e) {
        // Jika token tidak valid, hapus sesi
        print('Auto login failed: $e');
        await clearSession();

        // Jika ada data user di cache, kembalikan itu untuk sementara
        // (opsional, tergantung kebutuhan aplikasi)
        return cachedUser;
      }
    } catch (e) {
      print('Auto login error: $e');
      return null;
    }
  }
}
