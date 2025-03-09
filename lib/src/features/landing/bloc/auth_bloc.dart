import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();
  final Logger _logger = Logger();

  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event,emit) async {
      await _authRepository.signInSilently();
    });
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GuestSignInRequested>(_onGuestSignInRequested);
  }

  Future<void> _onGuestSignInRequested(
      GuestSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signInAsGuest(event.name);
      _logger.i("Guest user authenticated successfully: ${user.username}");
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      _logger.e("Guest authentication error: $e");
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {


      // final userEmail = await _authRepository.signInWithGoogle();
      // _logger.i("User authenticated successfully: $userEmail");
      // emit(AuthAuthenticated(userEmail: userEmail));
    } catch (e) {
      _logger.e("Authentication error: $e");
      emit(AuthError(error: e.toString()));
    }
  }
}
