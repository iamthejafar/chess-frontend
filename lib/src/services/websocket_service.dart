import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:logger/logger.dart';

class WebSocketService {
  StompClient? stompClient;
  final Logger logger = Logger();

  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws',
        onConnect: onConnected,
        beforeConnect: () async {
          logger.i("Connecting to WebSocket...");
        },
        onWebSocketError: (dynamic error) =>
            logger.e("WebSocket Error: $error"),

      ),
    );

    stompClient?.activate();
  }

  void onConnected(StompFrame frame) {
    logger.i("Connected to WebSocket!");
    initGame();
  }

  void initGame() {
    subscribeToGameUpdates();
    Map body =  {
      "userId": "",
      "isGuestUser": true
    };

    stompClient?.send(
      destination: '/app/init-game',
      body: jsonEncode(body),
      headers: {
        'content-type': 'application/json'
      },
    );


    logger.i("Sent INIT GAME event");
  }

  void subscribeToGameUpdates() {
    // Subscribe to user-specific queue
    stompClient?.subscribe(
        destination: "/user/queue/status",
        callback: (frame) {
          print("Status update received:");
          print(frame.body);
        }
    );

    stompClient?.subscribe(
        destination: "/user/queue/match",
        callback: (frame) {
          print("Match update received:");
          print(frame.body);
        }
    );
  }
  void disconnect() {
    stompClient?.deactivate();
  }
}
