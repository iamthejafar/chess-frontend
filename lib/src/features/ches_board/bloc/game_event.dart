part of 'game_bloc.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {}

class MovePiece extends GameEvent {
  final String from;
  final String to;
  final String? promotion;

  MovePiece(this.from, this.to, {this.promotion});
}

class PieceSelected extends GameEvent {
  final int pieceSquare;
  final String piece;

  PieceSelected(this.pieceSquare, this.piece);
}

class SquareSelected extends GameEvent {
  final int square;

  SquareSelected(this.square);
}

class OfferDrawRequested extends GameEvent {}

class AcceptDrawRequested extends GameEvent {}

class DeclineDrawRequested extends GameEvent {}

class ResignRequested extends GameEvent {}

class PromotionPieceSelected extends GameEvent {
  final String piece;

  PromotionPieceSelected(this.piece);
}

class PromotionSelectionCancelled extends GameEvent {}

class GameUpdate extends GameEvent {
  final Map<String, dynamic> data;

  GameUpdate(this.data);
}

class NavigateFirstMove extends GameEvent {}

class NavigatePreviousMove extends GameEvent {}

class NavigateNextMove extends GameEvent {}

class NavigateLastMove extends GameEvent {}

class NavigateToMove extends GameEvent {
  final int viewingIndex;
  NavigateToMove(this.viewingIndex);
}
