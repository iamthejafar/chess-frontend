import 'package:bishop/bishop.dart';
import 'package:chess/dotenv.dart';
import 'package:chess/src/features/ches_board/models/game_result_response.dart';
import 'package:chess/src/features/ches_board/models/game_state_response.dart';
import 'package:chess/src/features/landing/models/user_model.dart';
import 'package:chess/src/features/landing/repositories/user_repository.dart';
import 'package:chess/src/utils/status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/websocket_service.dart';
import 'package:logger/logger.dart';
import '../../../services/storage_service.dart';

import '../../../utils/chess_utils.dart';
import '../models/game_status_response.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final WebSocketService _webSocketService = WebSocketService();
  final StorageService _storageService = StorageService();

  final UserRepository _userRepository = UserRepository();
  final Logger _logger = Logger();

  String? _gameId;
  Game game = Game(variant: Variant.standard());

  GameBloc() : super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<MovePiece>(_onMovePiece);
    on<GameUpdate>(_onGameUpdate);
    on<PieceSelected>(_onPieceSelected);
    on<SquareSelected>(_onSquareSelected);
    on<OfferDrawRequested>(_onOfferDrawRequested);
    on<AcceptDrawRequested>(_onAcceptDrawRequested);
    on<DeclineDrawRequested>(_onDeclineDrawRequested);
    on<ResignRequested>(_onResignRequested);
    on<PromotionPieceSelected>(_onPromotionPieceSelected);
    on<PromotionSelectionCancelled>(_onPromotionSelectionCancelled);
    on<NavigateFirstMove>(_onNavigateFirstMove);
    on<NavigatePreviousMove>(_onNavigatePreviousMove);
    on<NavigateNextMove>(_onNavigateNextMove);
    on<NavigateLastMove>(_onNavigateLastMove);
    on<NavigateToMove>(_onNavigateToMove);

    _webSocketService.setOnMessageCallback(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    _logger.d('WebSocket message: $message');
    if (message['gameId'] != null) {
      _gameId = message['gameId'];
    }
    add(GameUpdate(message));
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    _logger.i('Starting game...');
    emit(GameLoading());
    try {
      _webSocketService.disconnect();
      game = Game(variant: Variant.standard());
      _webSocketService.connect();
      await _webSocketService.initGame();
    } catch (e) {
      _logger.e('Error starting game: $e');
      emit(GameError(e.toString()));
    }
  }

  Future<void> _onMovePiece(MovePiece event, Emitter<GameState> emit) async {
    try {
      if (_gameId == null) throw Exception('Game not started');

      final currentState =
          state is GameInProgress ? state as GameInProgress : null;
      if (currentState != null &&
          (!currentState.isAtLivePosition || currentState.isGameOver)) {
        return;
      }

      if (currentState != null &&
          event.promotion == null &&
          _isPromotionMove(event.from, event.to)) {
        emit(currentState.copyWith(
          selectedSquare: null,
          possibleMoves: [],
          pendingPromotionFrom: event.from,
          pendingPromotionTo: event.to,
        ));
        return;
      }

      _webSocketService.makeMove(
        _gameId!,
        event.from,
        event.to,
        promotion: event.promotion,
      );

      if (currentState != null) {
        emit(currentState.copyWith(
          selectedSquare: null,
          possibleMoves: [],
          pendingPromotionFrom: null,
          pendingPromotionTo: null,
        ));
      }
    } catch (e) {
      _logger.e('Error making move: $e');
      emit(GameError(e.toString()));
    }
  }

  void _onPieceSelected(PieceSelected event, Emitter<GameState> emit) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    final square = event.pieceSquare;

    if (!currentState.isAtLivePosition ||
        currentState.isGameOver ||
        currentState.isAwaitingPromotionChoice) {
      return;
    }
    if (currentState.selectedSquare != null &&
        currentState.possibleMoves.contains(square)) {
      final from = ChessUtils.indexToSquare(currentState.selectedSquare!);
      final to = ChessUtils.indexToSquare(square);
      add(MovePiece(from, to));
      return;
    }
    final moves = ChessUtils.getPossibleMoves(square, game);
    emit(currentState.copyWith(
      selectedSquare: square,
      possibleMoves: moves,
    ));
  }

  void _onSquareSelected(SquareSelected event, Emitter<GameState> emit) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    final square = event.square;

    if (!currentState.isAtLivePosition ||
        currentState.isGameOver ||
        currentState.isAwaitingPromotionChoice) {
      return;
    }

    if (currentState.selectedSquare != null &&
        currentState.possibleMoves.contains(square)) {
      final from = ChessUtils.indexToSquare(currentState.selectedSquare!);
      final to = ChessUtils.indexToSquare(square);
      add(MovePiece(from, to));
    } else {
      emit(currentState.copyWith(selectedSquare: null, possibleMoves: []));
    }
  }

  void _onPromotionPieceSelected(
    PromotionPieceSelected event,
    Emitter<GameState> emit,
  ) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;

    if (!_isValidPromotionPiece(event.piece)) {
      _logger.w('Invalid promotion piece: ${event.piece}');
      return;
    }

    final from = currentState.pendingPromotionFrom;
    final to = currentState.pendingPromotionTo;
    if (from == null || to == null) {
      return;
    }

    add(MovePiece(from, to, promotion: event.piece.toLowerCase()));
  }

  void _onPromotionSelectionCancelled(
    PromotionSelectionCancelled event,
    Emitter<GameState> emit,
  ) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    emit(currentState.copyWith(
      pendingPromotionFrom: null,
      pendingPromotionTo: null,
      selectedSquare: null,
      possibleMoves: [],
    ));
  }

  Future<void> _onOfferDrawRequested(
    OfferDrawRequested event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (currentState.isGameOver || currentState.hasPendingDrawOffer) return;

    final userId = await _resolveCurrentUserId(currentState);
    if (userId == null) {
      emit(GameError('Unable to identify current user'));
      return;
    }

    _webSocketService.offerDraw(currentState.gameId, userId);
    emit(currentState.copyWith(
      drawOffered: true,
      drawOfferedByUserId: userId,
      selectedSquare: null,
      possibleMoves: [],
    ));
  }

  Future<void> _onAcceptDrawRequested(
    AcceptDrawRequested event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (!currentState.isDrawOfferedByOpponent || currentState.isGameOver) return;

    final userId = await _resolveCurrentUserId(currentState);
    if (userId == null) {
      emit(GameError('Unable to identify current user'));
      return;
    }

    _webSocketService.acceptDraw(currentState.gameId, userId);
  }

  Future<void> _onDeclineDrawRequested(
    DeclineDrawRequested event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (!currentState.isDrawOfferedByOpponent || currentState.isGameOver) return;

    final userId = await _resolveCurrentUserId(currentState);
    if (userId == null) {
      emit(GameError('Unable to identify current user'));
      return;
    }

    _webSocketService.declineDraw(currentState.gameId, userId);
    emit(currentState.copyWith(
      drawOffered: false,
      drawOfferedByUserId: null,
    ));
  }

  Future<void> _onResignRequested(
    ResignRequested event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (currentState.isGameOver) return;

    final userId = await _resolveCurrentUserId(currentState);
    if (userId == null) {
      emit(GameError('Unable to identify current user'));
      return;
    }

    _webSocketService.resign(currentState.gameId, userId);
  }

  Future<void> _onGameUpdate(GameUpdate event, Emitter<GameState> emit) async {
    final data = event.data;
    final status = Status.fromName(data['type'] ?? '');

    switch (status) {
      case Status.error:
        emit(GameError(data['message'] ?? 'Unknown error'));
        return;
      case Status.matched:
        await _handleGameMatched(data, emit);
        return;
      case Status.move:
      case Status.resign:
      case Status.drawOffer:
      case Status.drawAccept:
      case Status.drawDecline:
        await _handleGameStateUpdate(
          data,
          emit,
          forceJumpToLive: status == Status.move,
        );
        return;
      default:
        emit(GameLoading());
        return;
    }
  }

  Future<void> _handleGameMatched(
    Map<String, dynamic> data,
    Emitter<GameState> emit,
  ) async {
    final gameStatus = GameStatusResponse.fromJson(data);
    final playerColor = gameStatus.message == 'WHITE' ? 0 : 1;

    final opponentUser = await _userRepository.getUser(gameStatus.opponentUserId);
    final user = _storageService.getUser();

    if (user != null) {
      _storageService.saveUser(user);
    }

    _gameId = gameStatus.gameId;

    emit(GameInProgress(
      game: game,
      playerColor: playerColor,
      opponentUser: opponentUser,
      user: user,
      gameId: gameStatus.gameId,
      drawOfferedByUserId: null,
      drawOffered: false,
      moveHistory: [game.fen],
    ));
  }

  Future<void> _handleGameStateUpdate(
    Map<String, dynamic> data,
    Emitter<GameState> emit, {
    bool forceJumpToLive = false,
  }) async {
    final gameState = GameStateResponse.fromJson(data);
    final appliedMove = _tryApplyIncomingMove(gameState);

    final currentUserId = await _storageService.getUserId();
    final playerColor = currentUserId == gameState.blackUserId ? 1 : 0;

    if (state is! GameInProgress) {
      return;
    }

    final currentState = state as GameInProgress;
    var newHistory = List<String>.from(currentState.moveHistory);

    if (newHistory.isEmpty) {
      newHistory.add(game.fen);
    }

    if (appliedMove && (newHistory.isEmpty || newHistory.last != game.fen)) {
      newHistory.add(game.fen);
    }

    final result = gameState.gameResult;
    final isTerminal = gameState.gameOver || result != null;

    // Force live view for backend move events; otherwise preserve current navigation.
    final targetViewingIndex = forceJumpToLive || appliedMove
        ? newHistory.length - 1
        : currentState.viewingIndex.clamp(0, newHistory.length - 1);

    final nextState = currentState.copyWith(
      game: game,
      playerColor: playerColor,
      gameResult: result,
      gameId: gameState.gameId,
      drawOffered: gameState.drawOffered,
      drawOfferedByUserId: gameState.drawOfferedByUserId,
      selectedSquare: null,
      possibleMoves: [],
      pendingPromotionFrom: null,
      pendingPromotionTo: null,
      moveHistory: newHistory,
      viewingIndex: targetViewingIndex,
    );

    emit(isTerminal ? GameOver.fromInProgress(nextState) : nextState);
  }

  bool _tryApplyIncomingMove(GameStateResponse gameState) {
    if (gameState.lastMove == null || gameState.lastMove!.isEmpty) {
      return false;
    }

    if (game.fen == gameState.fen) {
      return false;
    }

    final move = game.getMove(gameState.lastMove!);
    if (move == null) {
      _logger.w('Unable to parse incoming move: ${gameState.lastMove}');
      return false;
    }

    game.makeMove(move);
    return true;
  }

  Future<String?> _resolveCurrentUserId(GameInProgress state) async {
    if (state.user?.id != null && state.user!.id.isNotEmpty) {
      return state.user!.id;
    }
    final storedId = await _storageService.getUserId();
    if (storedId == null || storedId.isEmpty) {
      return null;
    }
    return storedId;
  }

  bool _isPromotionMove(String from, String to) {
    final fromIndex = ChessUtils.squareToIndex(from);
    if (fromIndex < 0 || fromIndex > 63) {
      return false;
    }

    final piece = game.boardSymbols()[fromIndex];
    if (piece != 'P' && piece != 'p') {
      return false;
    }

    if (to.length < 2) {
      return false;
    }

    final destinationRank = to[1];
    return (piece == 'P' && destinationRank == '8') ||
        (piece == 'p' && destinationRank == '1');
  }

  bool _isValidPromotionPiece(String piece) {
    final normalized = piece.toLowerCase();
    return normalized == 'q' ||
        normalized == 'r' ||
        normalized == 'b' ||
        normalized == 'n';
  }

  // --- Move Navigation -------------------------------------------------------

  void _onNavigateFirstMove(NavigateFirstMove event, Emitter<GameState> emit) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (!currentState.canGoBack) return;
    emit(currentState.copyWith(
      selectedSquare: null,
      possibleMoves: [],
      viewingIndex: 0,
    ));
  }

  void _onNavigatePreviousMove(
    NavigatePreviousMove event,
    Emitter<GameState> emit,
  ) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (!currentState.canGoBack) return;
    emit(currentState.copyWith(
      selectedSquare: null,
      possibleMoves: [],
      viewingIndex: currentState.viewingIndex - 1,
    ));
  }

  void _onNavigateNextMove(NavigateNextMove event, Emitter<GameState> emit) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (!currentState.canGoForward) return;
    emit(currentState.copyWith(
      selectedSquare: null,
      possibleMoves: [],
      viewingIndex: currentState.viewingIndex + 1,
    ));
  }

  void _onNavigateLastMove(NavigateLastMove event, Emitter<GameState> emit) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    if (!currentState.canGoForward) return;
    emit(currentState.copyWith(
      selectedSquare: null,
      possibleMoves: [],
      viewingIndex: currentState.moveHistory.length - 1,
    ));
  }

  void _onNavigateToMove(NavigateToMove event, Emitter<GameState> emit) {
    if (state is! GameInProgress) return;
    final currentState = state as GameInProgress;
    final clamped = event.viewingIndex.clamp(0, currentState.moveHistory.length - 1);
    if (clamped == currentState.viewingIndex) return;
    emit(currentState.copyWith(
      selectedSquare: null,
      possibleMoves: [],
      viewingIndex: clamped,
    ));
  }

  @override
  Future<void> close() {
    _webSocketService.disconnect();
    return super.close();
  }
}
