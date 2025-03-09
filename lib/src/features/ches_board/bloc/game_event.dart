part of 'game_bloc.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {}

class MovePiece extends GameEvent {
  final String from;
  final String to;

  MovePiece(this.from, this.to);
}

class GameUpdate extends GameEvent {
  final Map<String, dynamic> data;

  GameUpdate(this.data);
}
