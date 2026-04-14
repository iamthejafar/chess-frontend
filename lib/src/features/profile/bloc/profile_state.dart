part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  static const _unset = Object();

  final UserModel user;
  final bool isBusy;
  final String? busyMessage;
  final List<GameHistoryItem> games;
  final bool isHistoryLoading;
  final bool hasMoreHistory;
  final int nextHistoryPage;
  final int historyPageSize;
  final String? historyError;

  ProfileLoaded({
    required this.user,
    this.isBusy = false,
    this.busyMessage,
    this.games = const [],
    this.isHistoryLoading = false,
    this.hasMoreHistory = true,
    this.nextHistoryPage = 0,
    this.historyPageSize = 10,
    this.historyError,
  });

  ProfileLoaded copyWith({
    UserModel? user,
    bool? isBusy,
    Object? busyMessage = _unset,
    List<GameHistoryItem>? games,
    bool? isHistoryLoading,
    bool? hasMoreHistory,
    int? nextHistoryPage,
    int? historyPageSize,
    Object? historyError = _unset,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isBusy: isBusy ?? this.isBusy,
      busyMessage: identical(busyMessage, _unset)
          ? this.busyMessage
          : busyMessage as String?,
      games: games ?? this.games,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      nextHistoryPage: nextHistoryPage ?? this.nextHistoryPage,
      historyPageSize: historyPageSize ?? this.historyPageSize,
      historyError: identical(historyError, _unset)
          ? this.historyError
          : historyError as String?,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}

class ProfileUpdateSuccess extends ProfileState {
  final UserModel user;
  final String message;
  ProfileUpdateSuccess({required this.user, required this.message});
}

class ProfileDeleted extends ProfileState {}

