import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../features/landing/models/user_model.dart';
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

    _channel = WebSocketChannel.connect(
      Uri.parse(baseUrl),
    );
    _channel?.stream.listen(
      (message) {
        if (message == 'Connection established') {
          // Initial connection message, we can ignore this
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

  void joinGame() {
    final user = _storage.getUser();
    if (user == null || _channel == null) return;

    _channel?.sink.add(jsonEncode({
      "message": "JOIN",
      "uid": user.uid,
      "name": user.displayName,
    }));
  }

  void makeMove(String gameId, String from, String to, {String? promotionPiece}) {
    final user = _storage.getUser();
    if (user == null || _channel == null) return;

    final message = {
      "message": "MOVE",
      "gameId": gameId,
      "playerUid": user.uid,
      "from": from,
      "to": to,
    };

    if (promotionPiece != null) {
      message["promotionPiece"] = promotionPiece;
    }

    _channel?.sink.add(jsonEncode(message));
  }

  void resignGame(String gameId) {
    final user = _storage.getUser();
    if (user == null || _channel == null) return;

    _channel?.sink.add(jsonEncode({
      "message": "RESIGN",
      "gameId": gameId,
      "playerUid": user.uid,
    }));
  }

  void offerDraw(String gameId) {
    final user = _storage.getUser();
    if (user == null || _channel == null) return;

    _channel?.sink.add(jsonEncode({
      "message": "DRAW_OFFER",
      "gameId": gameId,
      "playerUid": user.uid,
    }));
  }

  void respondToDraw(String gameId, bool accepted) {
    final user = _storage.getUser();
    if (user == null || _channel == null) return;

    _channel?.sink.add(jsonEncode({
      "message": "DRAW_RESPONSE",
      "gameId": gameId,
      "playerUid": user.uid,
      "accepted": accepted,
    }));
  }

  void setOnMessageCallback(Function(Map<String, dynamic>) callback) {
    _onMessageCallback = callback;
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
  }
}
