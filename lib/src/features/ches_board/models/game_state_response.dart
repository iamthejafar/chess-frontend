import 'messages_enum.dart';
import 'game_result_response.dart';

class GameStateResponse {
  final Messages type;
  final String gameId;
  final String whiteUserId;
  final String blackUserId;
  final int moveCount;
  final String fen;
  final String? lastMove;
  final List<String> moves;
  final bool gameOver;
  final GameResultResponse? gameResult;
  final bool drawOffered;
  final String? drawOfferedByUserId;

  GameStateResponse({
    required this.type,
    required this.gameId,
    required this.whiteUserId,
    required this.blackUserId,
    required this.moveCount,
    required this.fen,
    this.lastMove,
    required this.moves,
    required this.gameOver,
    this.gameResult,
    required this.drawOffered,
    this.drawOfferedByUserId,
  });

  factory GameStateResponse.fromJson(Map<String, dynamic> json) {
    final gameResultJson = json['gameResult'] as Map<String, dynamic>?;
    return GameStateResponse(
      type: MessagesExtension.fromJson(json['type'] as String),
      gameId: json['gameId'] as String,
      whiteUserId: json['whiteUserId'] as String,
      blackUserId: json['blackUserId'] as String,
      moveCount: (json['moveCount'] as num).toInt(),
      fen: json['fen'] as String,
      lastMove: json['lastMove'] as String?,
      moves: (json['moves'] as List<dynamic>).map((e) => e as String).toList(),
      gameOver: json['gameOver'] as bool,
      gameResult: gameResultJson != null
          ? GameResultResponse.fromJson(gameResultJson)
          : null,
      drawOffered: json['drawOffered'] as bool? ?? false,
      drawOfferedByUserId: json['drawOfferedByUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
        'gameId': gameId,
        'whiteUserId': whiteUserId,
        'blackUserId': blackUserId,
        'moveCount': moveCount,
        'fen': fen,
        'lastMove': lastMove,
        'moves': moves,
        'gameOver': gameOver,
        'gameResult': gameResult?.toJson(),
        'drawOffered': drawOffered,
        'drawOfferedByUserId': drawOfferedByUserId,
      };
}
