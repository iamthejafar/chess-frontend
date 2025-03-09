import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/websocket_service.dart';
import 'package:logger/logger.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final WebSocketService _webSocketService = WebSocketService();
  final Logger _logger = Logger();
  String? _gameId;

  GameBloc() : super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<MovePiece>(_onMovePiece);
    on<GameUpdate>(_onGameUpdate);

    _webSocketService.setOnMessageCallback(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (message['gameId'] != null) {
      _gameId = message['gameId'];
    }

    if (message['type'] == 'ERROR') {
      emit(GameError(message['message']));
      return;
    }

    if (message['type'] == 'STATUS' && message['message'] == 'Waiting for an opponent...') {
      emit(GameWaitingForOpponent());
      return;
    }

    add(GameUpdate(message));
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    emit(GameLoading());
    try {
      _webSocketService.connect('ws://localhost:8080/ws/game'); // Replace with your backend URL
      _webSocketService.joinGame();
    } catch (e) {
      _logger.e('Error starting game: $e');
      emit(GameError(e.toString()));
    }
  }

  Future<void> _onMovePiece(MovePiece event, Emitter<GameState> emit) async {
    try {
      if (_gameId == null) {
        throw Exception('Game not started');
      }
      _webSocketService.makeMove(_gameId!, event.from, event.to);
    } catch (e) {
      _logger.e('Error making move: $e');
      emit(GameError(e.toString()));
    }
  }

  Future<void> _onGameUpdate(GameUpdate event, Emitter<GameState> emit) async {
    final data = event.data;
    emit(GameInProgress(
      fen: data['fen'],
      sideToMove: data['sideToMove'],
      isCheck: data['isCheck'] ?? false,
      isCheckmate: data['isCheckmate'] ?? false,
      isGameOver: data['isGameOver'] ?? false,
      whitePlayer: data['whitePlayer'],
      blackPlayer: data['blackPlayer'],
    ));
  }

  @override
  Future<void> close() {
    _webSocketService.disconnect();
    return super.close();
  }
}
