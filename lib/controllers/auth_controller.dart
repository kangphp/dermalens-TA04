import 'package:dermalens/models/user_model.dart';
import 'package:dermalens/services/api_service.dart';

class AuthController {
  // Fungsi Signup User
  Future<void> signupUser(String email, String password, String name) async {
    try {
      await ApiService.signup(email, password, name);
    } catch (error) {
      rethrow; // Lempar error untuk ditangani di UI
    }
  }

  // Fungsi Login User
  Future<UserModel> loginUser(String email, String password) async {
    try {
      return await ApiService.login(email, password);
    } catch (error) {
      rethrow; // Lempar error untuk ditangani di UI
    }
  }

  // Fungsi Get Profile
  Future<UserModel> getProfile() async {
    try {
      return await ApiService.getProfile();
    } catch (error) {
      rethrow;
    }
  }

  // Fungsi Update Profile
  Future<void> updateProfile(
      {String? name, String? phone, String? avatar}) async {
    try {
      await ApiService.updateProfile(name: name, phone: phone, avatar: avatar);
    } catch (error) {
      rethrow;
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (error) {
      rethrow;
    }
  }

  // Fungsi Check Auth Status
  Future<bool> isAuthenticated() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  // Fungsi Get Current User
  Future<UserModel?> getCurrentUser() async {
    try {
      return await getProfile();
    } catch (e) {
      return null;
    }
  }
}
