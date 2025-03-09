part of 'game_bloc.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameWaitingForOpponent extends GameState {}

class GameInProgress extends GameState {
  final String fen;
  final String sideToMove;
  final bool isCheck;
  final bool isCheckmate;
  final bool isGameOver;
  final Map<String, dynamic> whitePlayer;
  final Map<String, dynamic> blackPlayer;

  GameInProgress({
    required this.fen,
    required this.sideToMove,
    required this.isCheck,
    required this.isCheckmate,
    required this.isGameOver,
    required this.whitePlayer,
    required this.blackPlayer,
  });
}

class GameError extends GameState {
  final String message;

  GameError(this.message);
}
