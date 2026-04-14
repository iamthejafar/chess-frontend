import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final Logger _logger = Logger();
  StreamSubscription<UserModel?>? _authStreamSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {

    on<CheckAuthStatus>(_onCheckAuthStatus);

    on<GuestSignInRequested>(_onGuestSignInRequested);

    on<AuthenticationSucceeded>(_onAuthenticationSucceeded);

    on<AuthenticationFailed>(_onAuthenticationFailed);

    on<SignOutRequested>(_onSignOutRequested);

    _authStreamSubscription = _authRepository.authStateChanges.listen(
          (user) {
        if (user != null) {
          add(AuthenticationSucceeded(user: user));
        } else {
          // User signed out
          if (state is! AuthInitial) {
            add(SignOutRequested());
          }
        }
      },
      onError: (error) {
        add(AuthenticationFailed(error: error.toString()));
      },
    );

    // Check initial auth status
    add(CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _logger.i('Found existing session for: ${user.username}');
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
    }
  }

  Future<void> _onGuestSignInRequested(
      GuestSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signInAsGuest();
      _logger.i("Guest user authenticated successfully: ${user.username}");
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      _logger.e("Guest authentication error: $e");
      emit(AuthError(error: e.toString()));
    }
  }



  void _onAuthenticationSucceeded(
      AuthenticationSucceeded event, Emitter<AuthState> emit) {
    _logger.i('Authentication succeeded for: ${event.user.email}');
    emit(AuthAuthenticated(user: event.user));
  }

  void _onAuthenticationFailed(
      AuthenticationFailed event, Emitter<AuthState> emit) {
    _logger.e('Authentication failed: ${event.error}');
    emit(AuthError(error: event.error));
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      _logger.i('User signed out');
      emit(AuthInitial());
    } catch (e) {
      _logger.e("Sign out error: $e");
      emit(AuthError(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStreamSubscription?.cancel();
    _authRepository.dispose();
    return super.close();
  }
}