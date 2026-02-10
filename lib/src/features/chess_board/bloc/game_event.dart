part of 'game_bloc.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {
  final String? userId;
  final bool isGuest;

  StartGame({this.userId, this.isGuest = true});
}

class MovePiece extends GameEvent {
  final String from;
  final String to;
  final String? promotion;

  MovePiece({
    required this.from,
    required this.to,
    this.promotion,
  });
}

class GameUpdate extends GameEvent {
  final Map<String, dynamic> data;

  GameUpdate(this.data);
}

class GameMatched extends GameEvent {
  final Map<String, dynamic> gameData;

  GameMatched(this.gameData);
}

class GameStatusUpdate extends GameEvent {
  final String status;
  final String message;

  GameStatusUpdate(this.status, this.message);
}