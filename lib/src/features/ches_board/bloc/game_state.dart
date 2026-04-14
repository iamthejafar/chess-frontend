part of 'game_bloc.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameWaitingForOpponent extends GameState {}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}

class GameInProgress extends GameState {
  final Game game;
  final int? selectedSquare;
  final List<int> possibleMoves;
  final String gameId;
  final UserModel? opponentUser;
  final UserModel? user;
  final int playerColor;
  final GameResultResponse? gameResult;
  final String? drawOfferedByUserId;
  final bool drawOffered;
  final String? pendingPromotionFrom;
  final String? pendingPromotionTo;

  /// Full list of FEN strings starting from the initial position.
  final List<String> moveHistory;

  /// Index into [moveHistory] currently being viewed.
  /// When equal to `moveHistory.length - 1` the user is at the live position.
  final int viewingIndex;

  GameInProgress({
    required this.game,
    required this.gameId,
    this.opponentUser,
    this.user,
    required this.playerColor,
    this.selectedSquare,
    this.possibleMoves = const [],
    this.gameResult,
    this.drawOfferedByUserId,
    this.drawOffered = false,
    this.pendingPromotionFrom,
    this.pendingPromotionTo,
    List<String>? moveHistory,
    int? viewingIndex,
  })  : moveHistory = moveHistory ?? const [],
        viewingIndex = viewingIndex ??
            (moveHistory?.isNotEmpty == true ? moveHistory!.length - 1 : 0);

  // ── Derived booleans ──────────────────────────────────────────────────────

  bool get isWhite => playerColor == 0;

  /// Game is over when signalled via a non-null [gameResult].
  bool get isGameOver => gameResult != null;

  /// Whether the user is viewing the latest (live) position.
  bool get isAtLivePosition => viewingIndex >= moveHistory.length - 1;

  bool get canGoBack => viewingIndex > 0;

  bool get canGoForward => viewingIndex < moveHistory.length - 1;

  /// [drawOffered] is the single source of truth — no null-check fallback needed.
  bool get hasPendingDrawOffer => drawOffered;

  bool get isDrawOfferedByMe =>
      hasPendingDrawOffer && drawOfferedByUserId == user?.id;

  bool get isDrawOfferedByOpponent => hasPendingDrawOffer && !isDrawOfferedByMe;

  bool get isDrawResult => gameResult?.isDraw ?? false;

  bool get isAwaitingPromotionChoice =>
      pendingPromotionFrom != null && pendingPromotionTo != null;

  /// The FEN string for the position currently being viewed.
  String? get viewingFen =>
      moveHistory.isNotEmpty ? moveHistory[viewingIndex] : null;

  // ── copyWith ──────────────────────────────────────────────────────────────

  GameInProgress copyWith({
    Game? game,
    int? selectedSquare,
    List<int>? possibleMoves,
    String? gameId,
    UserModel? opponentUser,
    UserModel? user,
    int? playerColor,
    GameResultResponse? gameResult,
    List<String>? moveHistory,
    int? viewingIndex,
    bool? drawOffered,
    Object? drawOfferedByUserId = _copySentinel,
    Object? pendingPromotionFrom = _copySentinel,
    Object? pendingPromotionTo = _copySentinel,
  }) {
    final newHistory = moveHistory ?? this.moveHistory;
    return GameInProgress(
      game: game ?? this.game,
      gameId: gameId ?? this.gameId,
      opponentUser: opponentUser ?? this.opponentUser,
      user: user ?? this.user,
      playerColor: playerColor ?? this.playerColor,
      selectedSquare: selectedSquare,
      possibleMoves: possibleMoves ?? this.possibleMoves,
      gameResult: gameResult ?? this.gameResult,
      drawOffered: drawOffered ?? this.drawOffered,
      drawOfferedByUserId: identical(drawOfferedByUserId, _copySentinel)
          ? this.drawOfferedByUserId
          : drawOfferedByUserId as String?,
      pendingPromotionFrom: identical(pendingPromotionFrom, _copySentinel)
          ? this.pendingPromotionFrom
          : pendingPromotionFrom as String?,
      pendingPromotionTo: identical(pendingPromotionTo, _copySentinel)
          ? this.pendingPromotionTo
          : pendingPromotionTo as String?,
      moveHistory: newHistory,
      viewingIndex: viewingIndex ??
          (newHistory.isNotEmpty ? newHistory.length - 1 : 0),
    );
  }
}

class GameOver extends GameInProgress {
  GameOver({
    required super.game,
    required super.gameId,
    super.opponentUser,
    super.user,
    required super.playerColor,
    super.selectedSquare,
    super.possibleMoves,
    super.gameResult,
    super.drawOfferedByUserId,
    super.drawOffered,
    super.pendingPromotionFrom,
    super.pendingPromotionTo,
    super.moveHistory,
    super.viewingIndex,
  });

  factory GameOver.fromInProgress(GameInProgress state) {
    return GameOver(
      game: state.game,
      gameId: state.gameId,
      opponentUser: state.opponentUser,
      user: state.user,
      playerColor: state.playerColor,
      selectedSquare: state.selectedSquare,
      possibleMoves: state.possibleMoves,
      gameResult: state.gameResult,
      drawOfferedByUserId: state.drawOfferedByUserId,
      drawOffered: state.drawOffered,
      pendingPromotionFrom: state.pendingPromotionFrom,
      pendingPromotionTo: state.pendingPromotionTo,
      moveHistory: state.moveHistory,
      viewingIndex: state.viewingIndex,
    );
  }

  @override
  bool get isGameOver => true;

  @override
  GameOver copyWith({
    Game? game,
    int? selectedSquare,
    List<int>? possibleMoves,
    String? gameId,
    UserModel? opponentUser,
    UserModel? user,
    int? playerColor,
    GameResultResponse? gameResult,
    List<String>? moveHistory,
    int? viewingIndex,
    bool? drawOffered,
    Object? drawOfferedByUserId = _copySentinel,
    Object? pendingPromotionFrom = _copySentinel,
    Object? pendingPromotionTo = _copySentinel,
  }) {
    final newHistory = moveHistory ?? this.moveHistory;
    return GameOver(
      game: game ?? this.game,
      gameId: gameId ?? this.gameId,
      opponentUser: opponentUser ?? this.opponentUser,
      user: user ?? this.user,
      playerColor: playerColor ?? this.playerColor,
      selectedSquare: selectedSquare,
      possibleMoves: possibleMoves ?? this.possibleMoves,
      gameResult: gameResult ?? this.gameResult,
      drawOffered: drawOffered ?? this.drawOffered,
      drawOfferedByUserId: identical(drawOfferedByUserId, _copySentinel)
          ? this.drawOfferedByUserId
          : drawOfferedByUserId as String?,
      pendingPromotionFrom: identical(pendingPromotionFrom, _copySentinel)
          ? this.pendingPromotionFrom
          : pendingPromotionFrom as String?,
      pendingPromotionTo: identical(pendingPromotionTo, _copySentinel)
          ? this.pendingPromotionTo
          : pendingPromotionTo as String?,
      moveHistory: newHistory,
      viewingIndex: viewingIndex ??
          (newHistory.isNotEmpty ? newHistory.length - 1 : 0),
    );
  }
}

const Object _copySentinel = Object();

