import 'package:chess/src/features/landing/models/user_model.dart';
import 'package:chess/src/features/profile/models/game_history_models.dart';

import '../../../services/api_client.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _apiClient.get(
        '/api/user',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(_extractUserPayload(response.data));
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<UserModel?> updateUser({
    required String userId,
    required String name,
    required String username,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/user/$userId',
        data: {'name': name, 'username': username},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(_extractUserPayload(response.data));
      }
      return null;
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _apiClient.delete('user/$userId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Future<String?> uploadProfilePhoto({
    required String userId,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        '/api/user/$userId/photo',
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        fileKey: 'photo',
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        print("Response data: ${response.data}");
        final map = response.data as Map<String, dynamic>;
        return (map['fileName'] ?? map['picture'] ?? map['photo'])?.toString();
      }
      return null;
    } catch (e) {
      throw Exception('Error uploading profile photo: $e');
    }
  }

  String getProfilePhotoUrl(String fileName) {
    return _apiClient.resolveUrl('user/photo/$fileName');
  }

  Future<GameHistoryPage> getGameHistoryPage({
    required String userId,
    required int page,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/game/history',
        queryParameters: {
          'userId': userId,
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return GameHistoryPage.fromJson(_extractHistoryPayload(response.data));
      }
      throw Exception('Failed to fetch game history (status: ${response.statusCode})');
    } catch (e) {
      throw Exception('Error fetching game history: $e');
    }
  }

  Map<String, dynamic> _extractUserPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nested = raw['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return raw;
    }
    throw Exception('Invalid user payload format');
  }

  Map<String, dynamic> _extractHistoryPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nested = raw['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return raw;
    }
    throw Exception('Invalid game history payload format');
  }
}
