import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'storage_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? _onMessageCallback;
  final StorageService _storage = StorageService();

  void connect(String baseUrl) {
    final user = _storage.getUser();
    if (user == null) return;

    _channel = WebSocketChannel.connect(Uri.parse(baseUrl));
    _channel!.stream.listen(
      (message) {

        print("WebSocket Message: $message");
        if (message == 'Connection established') {
          return;
        }
        try {
          final data = jsonDecode(message);
          if (_onMessageCallback != null) {
            _onMessageCallback!(data);
          }
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      },
      onError: (error) {
        print('WebSocket Error: ${error.toString()}');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  Future<void> initGame() async {
    final userId = await _storage.getUserId();
    if (_channel == null) return;

    try{
      _channel!.sink.add(jsonEncode({"type": "INIT_GAME", "userId": userId}));

    } catch(e){
      print("Error initGame message: $e");
    }
  }

  void makeMove(
    String gameId,
    String from,
    String to, {
    String? promotion,
  }) {
    final user = _storage.getUser();
    if (user == null || _channel == null) return;

    final message = {
      "type": "MOVE",
      "gameId": gameId,
      "userId": user.id,
      "from": from,
      "to": to,
    };

    if (promotion != null) {
      message["promotion"] = promotion;
    }

    _channel?.sink.add(jsonEncode(message));
  }

  void resign(String gameId, String userId) {
    _sendGameAction(type: "RESIGN", gameId: gameId, userId: userId);
  }

  void offerDraw(String gameId, String userId) {
    _sendGameAction(type: "DRAW_OFFER", gameId: gameId, userId: userId);
  }

  void acceptDraw(String gameId, String userId) {
    _sendGameAction(type: "DRAW_ACCEPT", gameId: gameId, userId: userId);
  }

  void declineDraw(String gameId, String userId) {
    _sendGameAction(type: "DRAW_DECLINE", gameId: gameId, userId: userId);
  }

  void _sendGameAction({
    required String type,
    required String gameId,
    required String userId,
  }) {
    if (_channel == null) return;
    _channel?.sink.add(
      jsonEncode({"type": type, "gameId": gameId, "userId": userId}),
    );
  }

  void setOnMessageCallback(Function(Map<String, dynamic>) callback) {
    _onMessageCallback = callback;
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
  }
}
