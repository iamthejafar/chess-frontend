import 'package:get_storage/get_storage.dart';
import '../features/landing/models/user_model.dart';

class StorageService {
  final GetStorage _box = GetStorage();

  static const String _userKey = 'user_data';

  /// Save user data
  void saveUser(UserModel user) {
    _box.write(_userKey, user.toJson());
  }

  /// Get user data
  UserModel? getUser() {
    final data = _box.read(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// Clear user data
  void clearUser() {
    _box.remove(_userKey);
  }
}
