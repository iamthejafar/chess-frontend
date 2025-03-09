part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class InitAuth extends AuthEvent {}

class GuestSignInRequested extends AuthEvent {
  final String name;
  GuestSignInRequested({required this.name});
}

