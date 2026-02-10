part of 'game_bloc.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameWaitingForOpponent extends GameState {
  final String message;

  GameWaitingForOpponent({this.message = 'Looking for a match...'});
}

class GameInProgress extends GameState {
  final String gameId;
  final String fen;
  final String sideToMove;
  final bool isCheck;
  final bool isCheckmate;
  final bool isGameOver;
  final String whitePlayer;
  final String blackPlayer;
  final String? currentPlayerColor;
  final Map<String, dynamic>? lastMove;

  GameInProgress({
    required this.gameId,
    required this.fen,
    required this.sideToMove,
    required this.isCheck,
    required this.isCheckmate,
    required this.isGameOver,
    required this.whitePlayer,
    required this.blackPlayer,
    this.currentPlayerColor,
    this.lastMove,
  });
}

class GameError extends GameState {
  final String message;

  GameError(this.message);
}