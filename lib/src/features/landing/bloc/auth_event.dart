part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class GuestSignInRequested extends AuthEvent {
}

class SignOutRequested extends AuthEvent {}

class AuthenticationSucceeded extends AuthEvent {
  final UserModel user;
  AuthenticationSucceeded({required this.user});
}

class AuthenticationFailed extends AuthEvent {
  final String error;
  AuthenticationFailed({required this.error});
}