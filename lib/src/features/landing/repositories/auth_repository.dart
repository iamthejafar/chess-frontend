import 'package:chess/dotenv.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../services/api_client.dart';
import '../../../services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);
  final ApiClient _apiClient = ApiClient();

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted by user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _apiClient.post(
        'auth/google-signin',
        data: {
          'idToken': googleAuth.idToken!,
        },
      );

      if (response.statusCode == 200) {
        return googleUser.email;
      } else {
        throw Exception('Failed to authenticate with backend.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signInSilently() async {
    await _googleSignIn.signInSilently();
  }

  Future<UserModel> signInAsGuest(String name) async {
    try {
      final response = await _apiClient.post(
        'auth/guest',
        data: {
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        StorageService().saveUser(user);
        return user;
      } else {
        throw Exception('Failed to authenticate as guest.');
      }
    } catch (e) {
      debugPrint("Error signInAsGuest $e");
      throw Exception(e.toString());
    }
  }
}
