import 'package:get_storage/get_storage.dart';
import '../features/landing/models/user_model.dart';

class StorageService {
  final GetStorage _box = GetStorage();

  static const String _userKey = 'user_data';

  static const String _tokenKey = 'token';

  static const String _userId = 'userId';

  Future<void> saveUserId(String userId) async {
    await _box.write(_userId, userId);
  }

  Future<String?> getUserId() async {
    return _box.read(_userId);
  }

  Future<void> clearUserId() async {
    await _box.remove(_userId);
  }

  Future<void> saveToken(String token) async {
    await _box.write(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final token = await _box.read(_tokenKey);
    if (token == null) return null;
    return token;
  }

  Future<void> clearToken() async {
    await _box.remove(_tokenKey);
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    await _box.write(_userKey, user.toJson());
  }

  /// Get user data
  UserModel? getUser() {
    final data = _box.read(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _box.remove(_userKey);
  }
}
