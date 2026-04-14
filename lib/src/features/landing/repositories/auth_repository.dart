import 'package:chess/dotenv.dart';
import 'package:chess/src/features/landing/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../../../services/api_client.dart';
import '../../../services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();
  final UserRepository _userRepository = UserRepository();
  final Logger _logger = Logger();
  final GetStorage _box = GetStorage();

  static const _kLastAuthMethod = 'last_auth_method';
  static const _kAuthMethodGoogle = 'google';
  static const _kAuthMethodGuest = 'guest';

  final StreamController<UserModel?> _authStateController =
  StreamController<UserModel?>.broadcast();

  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  StreamSubscription<GoogleSignInAuthenticationEvent?>? _authSubscription;

  /// Initialize authentication repository
  Future<void> initialize() async {
    try {
      // Initialize Google Sign-In
      await _googleSignIn.initialize(clientId: clientId);

      // Always attach the stream listener — required by the GIS SDK on web.
      // The listener is harmless until the user actually clicks the rendered
      // button OR a silent sign-in succeeds (which we gate below).
      _authSubscription = _googleSignIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: _handleAuthenticationError,
      );

      // Only attempt silent sign-in if the user previously authenticated
      // with Google. This prevents the stream from firing unexpectedly for
      // users who chose guest login or have never signed in at all.
      final lastMethod = _box.read<String>(_kLastAuthMethod);
      if (lastMethod == _kAuthMethodGoogle) {
        await _googleSignIn.attemptLightweightAuthentication();
      } else {
        // No prior Google session — go straight to checking for a stored
        // backend session (e.g. guest JWT that is still valid).
        await _checkExistingSession();
      }
    } catch (e) {
      _logger.e('Failed to initialize Google Sign-In: $e');
    }
  }

  /// Check if user has an existing valid session
  Future<void> _checkExistingSession() async {
    try {
      await _storageService.getToken();
      final userId = await _storageService.getUserId();

      if (userId != null) {
        final user = await _userRepository.getUser(userId);
        if (user != null) {
          _authStateController.add(user);
        } else {
          await _clearSession();
        }
      }
    } catch (e) {
      _logger.w('No valid existing session: $e');
      await _clearSession();
    }
  }

  /// Handle Google Sign-In authentication events
  void _handleAuthenticationEvent(
      GoogleSignInAuthenticationEvent? event,
      ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      try {
        final idToken = event.user.authentication.idToken;

        if (idToken == null || idToken.isEmpty) {
          throw Exception('Failed to get ID token from Google');
        }

        // Persist that the user chose Google so silent sign-in is
        // attempted on the next cold start.
        await _box.write(_kLastAuthMethod, _kAuthMethodGoogle);

        // Authenticate with backend
        final authResponse = await _authenticateWithBackend(idToken);

        // Fetch full user details
        final user = await _userRepository.getUser(authResponse['userId']);

        if (user != null) {
          _authStateController.add(user);
        } else {
          throw Exception('Failed to fetch user details');
        }
      } catch (e) {
        _logger.e('Failed to authenticate with backend: $e');
        _authStateController.addError(e);
      }
      return;
    }

    // Sign-out event
    _logger.i('Authentication event: User signed out');
    await _box.remove(_kLastAuthMethod);
    _authStateController.add(null);
  }

  /// Handle authentication errors from Google Sign-In stream
  void _handleAuthenticationError(Object error) {
    _logger.e('Authentication error from stream: $error');
    _authStateController.addError(error);
  }

  /// Authenticate with backend using Google ID token
  Future<Map<String, dynamic>> _authenticateWithBackend(String idToken) async {
    _logger.i('Authenticating with backend using Google ID token...');
    try {
      final response = await _apiClient.post(
        'auth/google',
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        await _storageService.saveToken(data['token']);
        await _storageService.saveUserId(data['userId']);

        return data;
      } else {
        throw Exception(
          'Failed to authenticate with backend. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Backend authentication error: $e');
      rethrow;
    }
  }

  Future<UserModel> signInAsGuest() async {
    try {
      final response = await _apiClient.post('auth/guest');
      if (response.statusCode == 200) {
        _logger.i(
          'Guest user authenticated successfully with response: ${response.data}',
        );
        final data = response.data as Map<String, dynamic>;
        if (data['token'] != null) {
          await _storageService.saveToken(data['token']);
        }
        if (data['userId'] != null) {
          await _storageService.saveUserId(data['userId']);
        }

        // Persist that the user chose guest so Google silent sign-in is
        // skipped on the next cold start.
        await _box.write(_kLastAuthMethod, _kAuthMethodGuest);

        UserModel? userModel = await _userRepository.getUser(data['userId']);

        if (userModel != null) {
          _authStateController.add(userModel);
          await _storageService.saveUser(userModel);
          return userModel;
        } else {
          throw Exception('Failed to fetch user details');
        }
      } else {
        throw Exception(
          'Failed to authenticate as guest. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Error signing in as guest: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final user = await getCurrentUser();

      if (user?.isGuest != true) {
        await _googleSignIn.disconnect();
      }

      // Clear persisted auth method so neither Google silent sign-in
      // nor a stale guest session is restored on next launch.
      await _box.remove(_kLastAuthMethod);

      await _clearSession();
      _authStateController.add(null);

      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> _clearSession() async {
    await _storageService.clearToken();
    await _storageService.clearUserId();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _storageService.getUserId();
      if (userId == null) return null;

      return await _userRepository.getUser(userId);
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  /// Get current JWT token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    final userId = await _storageService.getUserId();
    return token != null && userId != null;
  }

  /// Refresh JWT token
  Future<void> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) {
        throw Exception('No token to refresh');
      }

      final response = await _apiClient.post(
        'auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storageService.saveToken(data['token']);
        _logger.i('Token refreshed successfully');
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      await signOut();
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }
}