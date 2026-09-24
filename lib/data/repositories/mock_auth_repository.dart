import '../models/user_model.dart';
import '../mock/mock_data.dart';

abstract class AuthRepository {
  Future<UserModel> getUserProfile();
  Future<bool> verifyOtp(String phone, String otp);
  Future<void> updatePreferences(String diet, String spice, List<String> allergies);
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockData.initialUser;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return otp == "123456";
  }

  @override
  Future<void> updatePreferences(String diet, String spice, List<String> allergies) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
